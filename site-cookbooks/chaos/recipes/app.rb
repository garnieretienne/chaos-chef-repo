#
# Cookbook Name:: chaos
# Recipe:: app
#
# Copyright 2013, Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Define the default ruby verion on the system
rbenv_global "1.9.3-p392" do
  action :create
end

# Add the deploy group (used by chaos tools)
# Add git user to deploy group
group "deploy" do
  system true
  members "git"
  append true
  action :create
end

# Create the bin folder (sourced by default profile on debian / ubuntu)
directory "#{node['gitolite']['admin_home']}/bin" do
  user "git"
  group "git"
  action :create
end

# Create the app folder
directory "#{node['chaos']['app']['dir']}" do
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

# Deployment hook
template "post-update" do
  path "#{node['gitolite']['admin_home']}/.gitolite/hooks/common/post-update"
  source "post-update"
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

# Add /usr/sbin to the user path (where nginx is)
execute "add /usr/sbin to PATH for git user" do
  command "echo \"PATH=/usr/sbin:\\$PATH\" >> #{node['gitolite']['admin_home']}/.profile"
  cwd "#{node['gitolite']['admin_home']}"
  user "git"
  group "git"
  action :run
  not_if "cat #{node['gitolite']['admin_home']}/.profile | grep \"PATH=/usr/sbin\""
end

# Generate keys to connect to service providers
execute "ssh-keygen -q -t rsa"
  cwd "#{node['gitolite']['admin_home']}"
  user "git"
  group "git"
  action :run
  not_if "ls #{node['gitolite']['admin_home']}/.ssh/id_rsa.pub"
end

# Install chaos route manager gem (move to its own recipe)
directory "#{node['gitolite']['admin_home']}/build" do
  user "git"
  group "git"
  action :create
end
git "hermes source" do
  repository "git://github.com/garnieretienne/chaos_hermes.git"
  destination "#{node['gitolite']['admin_home']}/build/hermes"
  user "git"
  group "git"
  action :checkout
end
execute "build hermes gem" do
  command "gem build chaos_hermes.gemspec"
  cwd "#{node['gitolite']['admin_home']}/build/hermes"
  user "git"
  group "git"
  action :run
  not_if "ls #{node['gitolite']['admin_home']}/build/hermes/chaos_hermes-0.0.1.gem"
end
rbenv_gem "hermes" do
  source "#{node['gitolite']['admin_home']}/build/hermes/chaos_hermes-0.0.1.gem"
  version "0.0.1"
  action :install
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

# Create the addons directory
directory "#{node['gitolite']['admin_home']}/addons" do
  user "git"
  group "git"
  action :create
end

# Allow git user to manage app processes
template "deploy sudo conf" do
  path "/etc/sudoers.d/deploy"
  source "sudo-deploy"
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
  mode 0644
  notifies :reload, 'service[nginx]'
end

# Install buildpacks
# Supported:
# * ruby (https://github.com/heroku/heroku-buildpack-ruby.git)
directory "#{node['chaos']['buildpacks']['dir']}" do
  mode 0755
  action :create
end
git "ruby buildpack" do
  repository "https://github.com/heroku/heroku-buildpack-ruby.git"
  destination "#{node['chaos']['buildpacks']['dir']}/ruby"
  action :checkout
end