#
# Cookbook Name:: chaos
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Create the nginx config for chaos
template "chaos.conf" do
  path "#{node['nginx']['dir']}/conf.d/chaos.conf"
  source "chaos.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, 'service[nginx]'
end

# Add the deploy group (used by chaos tools)
# Add git user to deploy group
group "deploy" do
  system true
  members "git"
  append true
  action :create
end

# Deployment script
template "deploy" do
  path "#{node['gitolite']['admin_home']}/bin/deploy"
  source "deploy"
  owner "git"
  group "git"
  mode "0755"
  action :create
end

# Processes starter script
template "starter" do
  path "#{node['gitolite']['admin_home']}/bin/starter"
  source "starter"
  owner "git"
  group "git"
  mode "0755"
  action :create
end
