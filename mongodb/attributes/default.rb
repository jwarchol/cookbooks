#
# Cookbook Name:: mongodb
# Attribute:: default
#
# Copyright 2011, IGN Entertainment
# Copyright 2010, CustomInk, LLC
#

default[:mongodb][:user]  = "mongodb"
default[:mongodb][:group] = "mongodb"

default[:mongodb][:bind_address] = "127.0.0.1"
default[:mongodb][:port]         = "27017"

default[:mongodb][:version]         = '1.8.3'
default[:mongodb][:package_version] = "#{mongodb[:version]}-mongodb"
default[:mongodb][:filename]        = "mongodb-linux-#{kernel[:machine] || 'i686'}-#{mongodb[:version]}"
default[:mongodb][:url]             = "http://downloads.mongodb.org/linux/#{mongodb[:file_name]}.tgz"

default[:mongodb][:binaries]   = "/usr/bin"
default[:mongodb][:data_dir]   = "/var/lib/mongodb"
default[:mongodb][:log_dir]    = "/var/log/mongodb"
default[:mongodb][:config_dir] = "/etc/mongodb"
default[:mongodb][:pid_dir]    = "/var/run"

default[:mongodb][:enable_rest]     = true