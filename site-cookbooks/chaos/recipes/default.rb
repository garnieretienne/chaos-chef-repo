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
