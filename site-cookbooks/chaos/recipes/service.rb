#
# Cookbook Name:: chaos
# Recipe:: service
#
# Copyright 2013, Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

user "#{node['chaos']['servicepacks']['user']}" do
  username "#{node['chaos']['servicepacks']['user']}"
  comment "Servicepacks user"
  shell "/bin/bash"
  home "#{node['chaos']['servicepacks']['dir']}"
  action :create
end

directory "#{node['chaos']['servicepacks']['dir']}" do
  user "#{node['chaos']['servicepacks']['user']}"
  group "#{node['chaos']['servicepacks']['user']}"
  recursive true
  action :create
end