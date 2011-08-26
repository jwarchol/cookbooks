#
# Cookbook Name:: mongodb
# Recipe:: monitoring
#
# Copyright 2011, IGN Entertainment
#

include_recipe 'git'
include_recipe 'munin'

git "/usr/share/munin/plugins/mongo-munin" do
  repository "https://github.com/ign/mongo-munin.git"
  reference "master"
  action :sync
end

package 'python-setuptools'
execute 'easy_install -q simplejson'

%w(mongo_btree mongo_conn mongo_lock mongo_mem mongo_ops).each do |monitor|
  link "/etc/munin/plugins/#{monitor}" do
    to "/usr/share/munin/plugins/mongo-munin/#{monitor}"
    action :create
    notifies :restart, resources(:service => 'munin-node')
    not_if { ::File.symlink?("/etc/munins/plugin/#{monitor}") }
  end
end