#
# Cookbook Name:: chaos
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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

# Install mason and foreman gems
gem_package "foreman" do
  action :install
end
gem_package "mason" do
  action :install
end
execute "add gem binary path to PATH and /usr/sbin for git user" do
  command "echo \"PATH=$(ruby -rubygems -e 'puts Gem.default_bindir'):/usr/sbin:\\$PATH\" >> #{node['gitolite']['admin_home']}/.profile"
  cwd "#{node['gitolite']['admin_home']}"
  user "git"
  group "git"
  action :run
  not_if "cat #{node['gitolite']['admin_home']}/.profile | grep \"$(ruby -rubygems -e 'puts Gem.default_bindir')\""
end

# Install chaos route manager gem (move to its own recipe)
directory "#{node['gitolite']['admin_home']}/build" do
  user "git"
  group "git"
  action :create
end
git "hermes source" do
  repository "git://github.com/garnieretienne/hermes.git"
  destination "#{node['gitolite']['admin_home']}/build/hermes"
  user "git"
  group "git"
  action :checkout
end
execute "build hermes gem" do
  command "gem build hermes.gemspec"
  cwd "#{node['gitolite']['admin_home']}/build/hermes"
  user "git"
  group "git"
  action :run
  not_if "ls #{node['gitolite']['admin_home']}/build/hermes/hermes-0.0.1.gem"
  notifies :install, "gem_package[hermes]", :immediately
end
gem_package "hermes" do
  source "#{node['gitolite']['admin_home']}/build/hermes/hermes-0.0.1.gem"
  action :nothing
end

# Allow git user to manage nginx routes
directory "#{node['gitolite']['admin_home']}/routes" do
  user "git"
  group "git"
  action :create
end
template "hermes sudo conf" do
  path "/etc/sudoers.d/hermes"
  source "sudo-hermes"
  owner "root"
  group "root"
  mode "0440"
  action :create
end

# Create the nginx config for chaos
template "chaos.conf" do
  path "#{node['nginx']['dir']}/conf.d/chaos.conf"
  source "chaos.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, 'service[nginx]'
end
