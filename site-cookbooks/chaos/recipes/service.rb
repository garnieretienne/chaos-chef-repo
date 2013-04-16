#
# Cookbook Name:: chaos
# Recipe:: service
#
# Copyright 2013, Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

user "servicepacks user" do
  username "#{node['chaos']['servicepacks']['user']}"
  comment "Servicepacks user"
  shell "/bin/bash"
  home "node['chaos']['servicepacks']['home']"
  action :create
end

directory "servicepacks directory" do
  path "#{node['chaos']['servicepacks']['dir']}"
  user "#{node['chaos']['servicepacks']['user']}"
  group "#{node['chaos']['servicepacks']['user']}"
  recursive true
  action :create
end

directory "servicepacks ssh folder" do
  path "#{node['chaos']['servicepacks']['home']}/.ssh"
  user "#{node['chaos']['servicepacks']['user']}"
  group "#{node['chaos']['servicepacks']['user']}"
  recursive true
  action :create
end