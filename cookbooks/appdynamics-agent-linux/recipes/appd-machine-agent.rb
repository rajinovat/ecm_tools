#
# Cookbook Name:: <appdynamics>
# Recipe:: <appd-machine-agent>
#
# Copyright (c) 2017 IBM Corporation, All Rights Reserved.

#This needs to be preinstalled a local gem file due ot internet connectivity issues in HPaaS
#include_recipe 'chef-sugar'
# include_recipe 'websphere-test::was_media_cli' unless vagrant?

# install for RHEL 6 based on
# http://www.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.installation.nd.doc/ae/tins_linuxsetup_rhel6.html?cp=SSAW57_8.5.5%2F1-5-0-4-2-2

package 'unzip'

set_limit '*' do
  type 'hard'
  item 'nofile'
  value 10240
  use_system true
end


user "#{node['appd']['agent_user']}" do
  comment 'AppDynamics User'
  uid '4444'
  gid '4444'
  home '/home/appduser'
  shell '/bin/bash'
  password "#{node['appd']['agent_user_password']}"
end

directory "#{node['appd']['agent_unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

directory "#{node['appd']['agent_install_location']}" do
  owner "node['appd']['agent_user']"
  group "node['appd']['agent_user']"
  mode '0755'
  action :create
  recursive true
end


remote_file "#{node['appd']['agent_unzip_path'][agent_package_name]}" do
  source "#{node['appd']['agent_package_url']}/installers/appd-agents/linux/#{node['appd']['agent_package_name']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


execute 'appd_unzip_asset' do
  command "unzip  #{node['appd']['agent_unzip_path']['agent_package_name']} -d ."
  cwd "#{node['appd']['agent_install_location']}"
end


remote_file "#{node['appd']['agent_install_location']}/conf/#{node['appd'][agent_ca_cert_name ]}" do
  source "#{node['appd']['agent_package_url']}/certs/#{node['appd'][agent_ca_cert_name]}"
  owner "#{node['appd']['agent_user']}"
  group "#{node['appd']['agent_group']}"
  mode '0755'
  action :create
end

file "#{node['appd']['install_location']/jre/lib/security/cacerts}" do
  content IO.read("#{node['appd']['appd_linux_package']['install_location']/conf/['ca_cert_name']}")
  action :create
end

# copy the configuration script on target node

template "#{node['appd'][['install_location']}/conf/controller-info.xml" do
  source "machine/controller-info.erb"
  owner node['db2']['instance']['name']
  mode 00755
   variables ({ 
    :controller_host => "#{node['appd']['controller_host']}",
    :controller_port => "#{node['appd']['controller_port']}",
    :controller_ssl =>  "#{node['appd']['controller_ssl']}",
    :controller_account_name => "#{node['appd']['controller_account_name']}",
    :controller_access_key => "#{node['appd']['controller_access_key']}",
    :controller_app_name => "#{node['appd']['controller_app_name']}",
    :controller_tier_name => "#{node['appd']['tier_name']}",
    :controller_node_name => #{node['appd']['appd_linux_package']['controller']['node_name']},
  })
end


template "#{node['appd']['appd_linux_package']['install_location']}/monitors/analytics-agent/monitor.xml" do
  source "machine/monitor.xml.erb"
  owner node['appd']['agent_user']
  mode 00755
   variables ({ 
    :agent_jre_enabled => "#{node['appd']['appd_linux_package']['controller']['host']}",
    :controller_port => "#{node['appd']['appd_linux_package']['controller']['port']}",
    :controller_ssl =>  "#{node['appd']['appd_linux_package']['controller']['controller_ssl']}",
    :controller_account_name => "#{node['appd']['user']}",
    :controller_accesskey => "#{node['appd']['accesskey']}",
    :controller_app_name => "#{node['appd']['app_name']}",
    :controller_tier_name => "#{node['appd']['tier_name']}",
    :controller_node_name => #{node['appd']['appd_linux_package']['controller']['node_name']},
  })
end

# copy the configuration script on target node
template "#{node['appd']['appd_linux_package']['install_location']}/etc/sysconfig/appdynamics-machine-agent" do
  source "machine/controller-info.erb"
  owner "appduser"
  mode 00755
   variables ({ 
    :agent_user => "#{node['appd']['appd_linux_package']['agent']['user']}",
    :agent_group  => "#{node['appd']['appd_linux_package']['agent']['group']}",
  })
end

link '/opt/appdynamics/machine-agent/etc/sysconfig/appdynamics-machine-agent' do
  to '/etc/sysconfig/appdynamics-machine-agent'
  link_type :hard
end

link '/opt/appdynamics/machine-agent/etc/init.d/appdynamics-machine-agent' do
  to '/etc/init.d/appdynamics-machine-agent'
  link_type :hard
end

# Extract DB2 zip files
execute 'appd_chkconfig' do
  command "chkconfig appdynamics-machine-agent --add"
  cwd "/etc/init.d"
end
