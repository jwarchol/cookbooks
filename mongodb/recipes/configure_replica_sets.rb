#
# Cookbook Name:: mongodb
# Recipe:: replication_set
#
# Copyright 2011, IGN Entertainment
#

def database_connect( instance_host )
  require 'mongo'
  
  Mongo::Connection.from_uri("mongodb://#{instance_host}", :slave_ok => true)
end

def ordered_hash_from_hash(regular_hash)
  ordered_hash = BSON::OrderedHash.new
  regular_hash.keys.sort.each do |key|
    ordered_hash[key.to_sym] = regular_hash[key]
  end
  ordered_hash
end

def is_master(connection)
  connection['admin'].command(ordered_hash_from_hash({:isMaster => true}))
end

mongods = node[:mongodb][:mongods]
mongods.uniq.compact.each do |instance|
  mongod              = instance["mongod"]
  port                = instance["port"]
  replication_set     = instance["replication_set"]
  
  next unless replication_set
  
  search_term = "mongodb_mongods_replication_set:#{replication_set}"
  replica_peers = search(:node, search_term).to_ary.collect {|host| host[:fqdn] }
  replica_peers.delete node[:fqdn]
  
  # STEP 1: wait for the server to become available, and get current status
  local_db = master_status = nil
  instance_host = "#{node[:fqdn]}:#{port}"
  Chef::Log.info "Connecting to #{instance_host}..."
  
  while (local_db == nil) or (master_status == nil)
    begin
      local_db = database_connect(instance_host)
      master_status = is_master(local_db)
    rescue Exception => e
      Chef::Log.warn "Error getting local master status: #{e.message}"
      return false
    end
  end
  
  # STEP 2: configure replication based on current status
  if master_status['ismaster'] or master_status['secondary']
    Chef::Log.info "Replication is already configured: #{master_status.inspect}"
  else
    Chef::Log.info "Replication is not configured (#{master_status['info']})"
    while is_master(local_db)['info'] =~ /local.system.replset .*EMPTYUNREACHABLE/
      Chef::Log.info "Replication is not configured: #{is_master(local_db)['info']}"
      sleep 10
    end
    if replica_peers.empty?
      # Configure as the lone master
      Chef::Log.info "No other servers in replica set #{replication_set}; becoming master"
      Chef::Log.info "Setting master to: #{instance_host}"
      local_db['admin'].command(ordered_hash_from_hash(
        :replSetInitiate => {
          "_id" => replication_set,
          "members" => [{ "_id" => 0, "votes" => 2, "host" => instance_host }]
        }
      ))
    else
      # Configure as a slave
      Chef::Log.info "Found replica peers: #{replica_peers.join ','}"
      replication_stared = false
      replica_peers.each do |server|
        if not replication_stared
          Chef::Log.info "Retrieving replication settings from #{server}..."
          peer_db = database_connect("#{server}:#{node[:mongodb][:port]}")
          repl_settings = peer_db['local']["system.replset"].find_one
          Chef::Log.info "Replication settings for #{server}: "+ repl_settings.inspect

          if is_master(peer_db)['ismaster']
            Chef::Log.info "Starting replication from master: #{server}..."
            active_peers = repl_settings['members'].collect {|m| m['host'] }
            if active_peers.include? instance_host
              Chef::Log.error "Host #{instance_host} already in replica set!"
            else
              repl_settings["version"] += 1   # increment config version
              max_id = repl_settings['members'].inject(0) do |max, peer|
                peer['_id'] > max ? peer['_id'] : max
              end
              repl_settings['members'].push( {'host' => instance_host, '_id' => max_id+1})
              bson = ordered_hash_from_hash(:replSetReconfig => repl_settings)
              Chef::Log.info "Pushing replication settings: #{repl_settings.inspect}"
              peer_db['admin'].command(bson)
              replication_stared = true
            end
          end
        end
      end
    end
  end

  # STEP 3: wait for the local replication status to be OK
  while not (is_master(local_db)['ismaster'] or is_master(local_db)['secondary'])
    Chef::Log.info "Waiting for local replication (#{is_master(local_db)['info']})"
    sleep 10
  end
  Chef::Log.info("Local replication status: #{is_master(local_db).inspect}")
  
end