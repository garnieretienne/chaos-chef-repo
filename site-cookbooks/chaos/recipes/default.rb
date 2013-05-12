#
# Cookbook Name:: chaos
# Recipe:: default
#
# Copyright 2013, Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Create an admin user
admin_key = "/root/admin_key"
if Dir.exist? admin_key then
  Dir.foreach admin_key do |entry|
    if File.file? "#{admin_key}/#{entry}" and entry =~ /.*\.pub/ then
      user_name = entry.split(/(.*)\.pub/)[1]
      key = "#{admin_key}/#{entry}"
      key_content = `cat #{admin_key}/#{entry}`.chomp

      user "admin #{user_name}" do
        username user_name
        comment "System Operator"
        shell "/bin/bash"
        home "/home/#{user_name}"
        supports :manage_home => true
        action :create
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
        action :run
        not_if "cat /home/#{user_name}/.ssh/authorized_keys | grep '#{key_content}'"
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

  # Install Dotdeb repository
  # See: http://www.dotdeb.org/about/
  template "dotdeb.list" do
    path "/etc/apt/sources.list.d/dotdeb.list"
    source "dotdeb.list"
    owner "root"
    group "root"
    mode 0644
    action :create
    notifies :run, "execute[enable dotdeb repository]", :immediately
  end

  # Download and register the dotdeb GPG key and update apt database
  execute "enable dotdeb repository" do
    command "wget http://www.dotdeb.org/dotdeb.gpg && cat dotdeb.gpg | apt-key add - && apt-get update"
    action :nothing
  end
end