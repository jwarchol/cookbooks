#
# Cookbook Name:: mongodb
# Recipe:: install
#
# Copyright 2011, IGN Entertainment
# Copyright 2010, CustomInk, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

group node[:mongodb][:group] do
  action [ :create, :manage ]
end

user node[:mongodb][:user] do
  comment "MongoDB Server"
  gid node[:mongodb][:group]
  action [ :create, :manage ]
end

include_recipe "mongodb::10gen_repo"

package "mongo-10gen-server" do
  action :install
end

# Add bin directory to everyone's path for bash
template "/etc/profile.d/mongodb.sh" do
  source "mongo.sh.erb"
  owner "root"
  group "root"
  mode 0755
end

# Add bin directory to everyone's path for csh
template "/etc/profile.d/mongodb.csh" do
  source "mongo.csh.erb"
  owner "root"
  group "root"
  mode 0755
end

# cleanup stuff from the 10gen rpm
file "/etc/mongod.conf" do
  action :delete
end

file "/etc/init.d/mongod" do
  action :delete
end

directory "/var/log/mongo" do
  action :delete
  recursive true
  not_if { node[:mongodb][:log_dir].eql?('/var/log/mongo') }
end

# Make sure the pid directory is created
directory node[:mongodb][:pid_dir] do
  action :create
  recursive true
end

# make sure logrotate.d is created
directory "/etc/logrotate.d" do
  recursive true
end