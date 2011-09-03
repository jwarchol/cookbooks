#
# Cookbook Name:: mongodb
# Resource:: instance
#
# Copyright:: 2011, IGN Entertainment
#

actions :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :port, :kind_of => Integer, :default => 27017
attribute :sharded, :kind_of => [TrueClass, FalseClass], :default => false
attribute :config_server, :kind_of => [TrueClass, FalseClass], :default => false
attribute :replication_set, :kind_of => [String, FalseClass], :default => false
attribute :enable_rest, :kind_of => [TrueClass, FalseClass], :default => true
attribute :config_servers, :kind_of => Array, :default => Array.new
attribute :additional_options, :kind_of => Hash
