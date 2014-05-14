#
# Cookbook Name:: redis
# Attribute:: default
#
# Copyright 2013, PSCE
#
# All rights reserved - Do Not Redistribute
#

default[:redis][:version]   = '2.6.17'

default[:redis][:home_dir]  = '/opt/redis'
default[:redis][:conf_dir]  = '/etc/redis'
default[:redis][:data_dir]  = '/var/lib/redis'
default[:redis][:log_dir]   = '/var/log/redis'
default[:redis][:loglevel]  = 'notice'
default[:redis][:user]      = 'redis'
default[:redis][:port]      = 6379
default[:redis][:bind]      = '127.0.0.1'
