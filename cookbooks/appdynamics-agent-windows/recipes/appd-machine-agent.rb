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

user 'appduser' do
  comment 'AppDynamics User'
  uid '4444'
  gid '4444'
  home '/home/appduser'
  shell '/bin/bash'
  password 'changeit2018'
end

directory "#{node['appd']['appd_linux_package']['package_unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

directory "#{node['appd']['appd_linux_package']['install_location']}" do
  owner 'appduser'
  group 'appduser'
  mode '0755'
  action :create
  recursive true
end



#Download DB2 zip file
remote_file "#{node['appd']['package']['appd_unzip_path']}/#{node['appd']['appd_linux_package']['package_name']}" do
  source "#{node['appd']['package_url']}#{node['appd']['appd_linux_package']['package_name']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Extract DB2 zip files
execute 'appd_unzip_asset' do
  command "unzip  #{node['appd']['appd_linux_package']['package_name']} -d ."
  cwd "#{node['appd']['appd_linux_package']['install_location']}"
end



#Download DB2 zip file
remote_file "#{node['appd']['package']['appd_unzip_path']}/#{node['appd']['appd_linux_package']['package_unzip_path']['cacerts.jks']}" do
  source "#{node['appd']['ca_cert_url'][ca_cert_name]}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


file "#{node['appd']['appd_linux_package']['install_location']/conf/['ca_cert_name']}" do
  content IO.read("#{node['appd']['package']['appd_unzip_path']}/#{node['appd']['appd_linux_package']['package_unzip_path']['cacerts.jks']}")
  action :create
end



# copy the configuration script on target node
template "#{node['appd']['appd_linux_package']['install_location']}/conf/controller-info.xml" do
  source "controller-info.erb"
  owner node['db2']['instance']['name']
  mode 00755
   variables ({ 
    :controller_host => "#{node['appd']['appd_linux_package']['controller']['host']}",
    :controller_port => "#{node['appd']['appd_linux_package']['controller']['port']}",
    :controller_ssl =>  "#{node['appd']['appd_linux_package']['controller']['controller_ssl']}",
    :controller_user => "#{node['appd']['appd_linux_package']['controller']['controller_user']}",
    :controller_accesskey => "#{node['appd']['appd_linux_package']['controller']['controller_accesskey']}",
    :app_name => "#{node['appd']['appd_linux_package']['['controller']']['app_name']}",
    :tier_name => "#{node['appd']['appd_linux_package']['controller']['tier_name']}",
    :node_name => #{node['appd']['appd_linux_package']['controller']['node_name']},
    :controller_port => #{node['appd']['appd_linux_package']['controller']['host']},
         
  })
end





install_mgr 'ibm-im install' do
  install_package "#{node['ibm_installmgr']['package_url']}/#{node['ibm_installmgr']['package_name']}"
  download_temp_dir node['ibm_installmgr']['package_unzip_path']
  install_package_sha256 '426261bc1be21e236a45e55c66a452484661fcbb5885d28cbf4408513fba0c42'
  install_dir "#{node['ibm_installmgr']['install_location']}/InstallationManager"
  package_name 'com.ibm.cic.agent'
  ibm_root_dir node['ibm_installmgr']['package_unzip_path']
  service_user node['was_user_setup']['username']
  service_group node['was_user_setup']['usergroup']
  access_rights access_right
  manage_user node['was_user_setup']['manage_user']
end

directory "#{node['wasnd']['package']['wasnd_unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

directory "#{node['wasnd']['package']['wasnd_fp11unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

directory "#{node['wasnd']['package']['wasnd_fp12unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

directory "#{node['wasnd']['package']['wasjava_unzip_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

remote_file "#{node['wasnd']['package']['wasjava_unzip_path']}/#{node['wasnd']['packages']['wasjava']}" do
  source "#{node['wasnd']['package_url']}#{node['wasnd']['packages']['wasjava']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

execute "unzip_#{node['wasnd']['packages']['wasjava']}" do
  command "unzip  -o #{node['wasnd']['packages']['wasjava']} -d ."
  cwd "#{node['wasnd']['package']['wasjava_unzip_path']}"
end
execute 'remove_wasnd_assets' do
  command "rm -rf *.zip"
  cwd "#{node['wasnd']['package']['wasjava_unzip_path']}"
end
# Download all WAS ND and Fix Packs
#Download WASND main zip file
node['wasnd']['packages']['wasnd'].split(',').each do |packages|
  remote_file "#{node['wasnd']['package']['wasnd_unzip_path']}/#{packages}" do
    source "#{node['wasnd']['package_url']}#{packages}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create_if_missing
  end
end


# Extract WASND zip files
node['wasnd']['packages']['wasnd'].split(',').each do |packages|
  execute "unzip_#{packages}" do
    command "unzip  -o #{packages} -d ."
    cwd "#{node['wasnd']['package']['wasnd_unzip_path']}"
  end
end

execute 'remove_wasnd_assets' do
  command "rm -rf *.zip"
  cwd "#{node['wasnd']['package']['wasnd_unzip_path']}"
end


ibm_package 'WAS ND install' do
  imcl_dir node['wasnd']['instance']['eclipse_tools_location']
  package node['wasnd']['package']['wasnd_package_features']
  install_dir node['wasnd']['instance']['install_location']
  repositories [node['wasnd']['package']['wasnd_unzip_path']]
  service_user node['was_user_setup']['username']
  service_group node['was_user_setup']['usergroup']
  access_rights access_right
  manage_user node['was_user_setup']['manage_user']
  action :install
end

#Download WASND FP11 main zip file
node['wasnd']['packages']['wasndfp11'].split(',').each do |packages|
  remote_file "#{node['wasnd']['package']['wasnd_fp11unzip_path']}/#{packages}" do
    source "#{node['wasnd']['package_url']}#{packages}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create_if_missing
  end
end

#Download WASND FP12 main zip file
node['wasnd']['packages']['wasndfp12'].split(',').each do |packages|
  remote_file "#{node['wasnd']['package']['wasnd_fp12unzip_path']}/#{packages}" do
    source "#{node['wasnd']['package_url']}#{packages}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create_if_missing
  end
end


#Extract the wasnd fp11 packages
node['wasnd']['packages']['wasndfp11'].split(',').each do |packages|
  execute "unzip_#{packages}" do
    puts "packages ------------" + packages
    command "unzip  -o #{packages} -d ."
    cwd "#{node['wasnd']['package']['wasnd_fp11unzip_path']}"
  end
end

execute 'remove_wasndfp11_assets' do
  command "rm -rf *.zip"
  cwd "#{node['wasnd']['package']['wasnd_fp11unzip_path']}"
end

ibm_fixpack 'WAS ND Fixpack 11 install' do
  imcl_dir node['wasnd']['instance']['eclipse_tools_location']
  package node['wasnd']['package']['wasnd_fp11_package_feature']
  install_dir node['wasnd']['instance']['install_location']
  repositories [node['wasnd']['package']['wasnd_fp11unzip_path']]
  service_user node['was_user_setup']['username']
  service_group node['was_user_setup']['usergroup']
  access_rights access_right
  manage_user node['was_user_setup']['manage_user']
  action :install
end

#Extract the wasnd fp12 packages
node['wasnd']['packages']['wasndfp12'].split(',').each do |packages|
  execute "unzip_#{packages}" do
    puts "packages ------------" + packages
    command "unzip  -o #{packages} -d ."
    cwd "#{node['wasnd']['package']['wasnd_fp12unzip_path']}"
  end
end
execute 'remove_wasndfp12_assets' do
  command "rm -rf *.zip"
  cwd "#{node['wasnd']['package']['wasnd_fp12unzip_path']}"
end

ibm_fixpack 'WAS ND Fixpack 12 install' do
  imcl_dir node['wasnd']['instance']['eclipse_tools_location']
  package node['wasnd']['package']['wasnd_fp12_package_feature']
  install_dir node['wasnd']['instance']['install_location']
  repositories [node['wasnd']['package']['wasnd_fp12unzip_path']]
  service_user node['was_user_setup']['username']
  service_group node['was_user_setup']['usergroup']
  access_rights access_right
  manage_user node['was_user_setup']['manage_user']
  action :install
end

ibm_package 'WAS JAVA install' do
  imcl_dir node['wasnd']['instance']['eclipse_tools_location']
  package node['wasnd']['package']['wasjava_package_feature']
  install_dir node['wasnd']['instance']['install_location']
  repositories [node['wasnd']['package']['wasjava_unzip_path']]
  service_user node['was_user_setup']['username']
  service_group node['was_user_setup']['usergroup']
  access_rights access_right
  manage_user node['was_user_setup']['manage_user']
  action :install
end
