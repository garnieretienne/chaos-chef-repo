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
