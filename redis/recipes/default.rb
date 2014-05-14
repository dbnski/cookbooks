#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2013, PSCE
#
# All rights reserved - Do Not Redistribute
#

redis_version = node[:redis][:version]
redis_archive = "redis-#{redis_version}.tar.gz"

redis_home = node[:redis][:home_dir]
redis_link = redis_home + '/current'
redis_vdir = redis_home + "/redis-#{redis_version}"

package 'build-essential'

user node[:redis][:user] do
  action :create
  system true
  shell '/bin/false'
end

directory node[:redis][:home_dir] do
  owner 'root'
  mode 00755
  action :create
  not_if { File.exists?(node[:redis][:home_dir]) }
end

directory node[:redis][:conf_dir] do
  owner 'root'
  mode 00755
  action :create
end

directory node[:redis][:data_dir] do
  owner node[:redis][:user]
  mode 00755
  action :create
end

directory node[:redis][:log_dir] do
  owner node[:redis][:user]
  mode 00755
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/#{redis_archive}" do
  source "http://download.redis.io/releases/#{redis_archive}"
  action :create_if_missing
  not_if { File.exists?("#{redis_vdir}/bin") }
end

bash "build redis-#{redis_version}" do
  code <<-EOH
    tar -x -z -C /tmp -f #{Chef::Config[:file_cache_path]}/#{redis_archive}
    cd "/tmp/redis-#{redis_version}"
    make PREFIX="#{redis_home}/redis-#{redis_version}" install
    rm -rf "/tmp/redis-#{redis_version}"
  EOH
  creates "#{redis_home}/redis-#{redis_version}/bin/redis-server"
end

link redis_link do
  to "#{redis_vdir}"
  owner 'root'
  group 'root'
  link_type :symbolic
  not_if "[ $(readlink '#{redis_link}') == '#{redis_vdir}' ]"
end

service 'redis' do
  provider Chef::Provider::Service::Upstart
  subscribes :restart, 'link[redis_link]'
  supports :restart => true, :start => true, :stop => true
end

template "#{node[:redis][:conf_dir]}/redis.conf" do
  source 'conf/redis.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, 'service[redis]'
end

template '/etc/init/redis.conf' do
  source 'init/redis.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, 'service[redis]'
end

service 'redis' do
  action [:enable, :start]
end
