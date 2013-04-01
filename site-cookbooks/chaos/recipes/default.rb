#
# Cookbook Name:: chaos
# Recipe:: default
#
# Copyright 2013, Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Define the default ruby verion on the system
rbenv_global "1.9.3-p392" do
  action :create
end

# Create an admin user
admin_key = "/root/admin_key"
if Dir.exist? admin_key then
  Dir.foreach admin_key do |entry|
    if File.file? "#{admin_key}/#{entry}" and entry =~ /.*\.pub/ then
      user_name = entry.split(/(.*)\.pub/)[1]
      key = "#{admin_key}/#{entry}"

      user "admin #{user_name}" do
        username user_name
        comment "Admin user"
        shell "/bin/bash"
        home "/home/#{user_name}"
        supports :manage_home=>true
        action :create
        notifies :run, "execute[#{user_name} key]"
        notifies :run, "execute[ask #{user_name} to change its password on first login]"
      end
 
      directory "/home/#{user_name}/.ssh" do
        user user_name
        group user_name
        mode 0700
        action :create
      end

      file "/home/#{user_name}/.ssh/authorized_keys" do
        owner user_name
        group user_name
        mode "0700"
        action :create
      end

      execute "#{user_name} key" do
        command "cat #{key} >> /home/#{user_name}/.ssh/authorized_keys"
        action :nothing
      end

      execute "ask #{user_name} to change its password on first login" do
        command "echo #{user_name}:#{user_name} | chpasswd && chage -d 0 #{user_name}"
        action :nothing
      end

      group "sudo" do
        system true
        members user_name
        append true
        action :create
      end
    end
  end
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

# Create the app folder (sourced by default profile on debian / ubuntu)
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

# Install mason and foreman gems
rbenv_gem "foreman" do
  action :install
end
rbenv_gem "mason" do
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
end
rbenv_gem "hermes" do
  source "#{node['gitolite']['admin_home']}/build/hermes/hermes-0.0.1.gem"
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
  mode 00644
  notifies :reload, 'service[nginx]'
end
