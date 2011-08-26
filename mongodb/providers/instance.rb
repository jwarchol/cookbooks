#
# Cookbook Name:: mongodb
# Provider:: instance
#
# Copyright:: 2011, IGN Entertainment
#

require 'chef/mixin/command'
require 'chef/mixin/language'
require 'chef/mixin/language_include_recipe'
include Chef::Mixin::Command
include Chef::Mixin::LanguageIncludeRecipe

action :create do
  # Create directories
  directories = %W(#{node[:mongodb][:log_dir]}/#{new_resource.name}
                   #{node[:mongodb][:data_dir]}/#{new_resource.name})
  
  directories << "#{node[:mongodb][:data_dir]}/#{new_resource.name}_config" if new_resource.sharded
  
  directories.each do |dir|
    directory dir do
      owner node[:mongodb][:user]
      group node[:mongodb][:group]
      mode 0755
      recursive true
      action :create
      not_if { ::File.directory?(dir) }
    end
  end
  
  # Figure out configuration options
  ports = {:mongod => node[:mongodb][:port]}
  ports.merge!({:mongod => node[:mongodb][:port].to_i - 1, :shard => node[:mongodb][:port], :configdb => 27019}) if new_resource.sharded
  
  options = %w(journal)
  options << "shardsvr" if new_resource.sharded
  
  base_path     = "#{node[:mongodb][:data_dir]}/#{new_resource.name}"
  config        = "#{node[:mongodb][:config_dir]}/mongodb_#{new_resource.name}.conf"
  instance      = new_resource.name
  is_sharded    = new_resource.sharded
  run_configsvr = new_resource.config_servers.find {|s| s.include?(node[:fqdn]) }
  configsvrs    = new_resource.config_servers.join(',')
  
  # Create bluepill config
  bluepill_service "mongodb_#{new_resource.name}" do
    cookbook      'mongodb'
    source        'mongo.pill.erb'
    path          base_path
    config        config
    ports         ports
    instance      instance
    shard         is_sharded
    run_configsvr run_configsvr
    configsvrs    configsvrs
    options       options.collect {|o| '--' + o}.join(' ')
  end
  
  # create config directory and file
  directory "#{node[:mongodb][:config_dir]}" do
    action :create
    owner "root"
    group "root"
    mode 0755
  end
  
  template "/etc/mongodb/mongodb_#{new_resource.name}.conf" do
    cookbook 'mongodb'
    source 'mongodb.conf.erb'
    variables(
      :database_path       => "#{node[:mongodb][:data_dir]}/#{new_resource.name}",
      :port                => ports[:mongod],
      :log_path            => "#{node[:mongodb][:log_dir]}/#{new_resource.name}",
      :rest                => new_resource.enable_rest,
      :replication_set     => new_resource.replication_set,
      :additional_settings => new_resource.additional_options
    )
    owner "root"
    group "root"
    mode 0744
  end
  
  template "/etc/logrotate.d/mongo_#{new_resource.name}" do
    cookbook 'mongodb'
    source "mongo_logrotate.erb"
    owner "root"
    group "root"
    mode   0644
    variables(
      :mongod => new_resource.name
    ) 
  end
end


