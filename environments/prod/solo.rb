file_cache_path    "/var/chef/cache"
file_backup_path   "/var/chef/backup"
cookbook_path ["/chef-repo/cookbooks"]
role_path "/chef-repo/roles"

log_level :info
verbose_logging false

encrypted_data_bag_secret "/document_root/encrypted_data_bag_secret"

data_bag_path "/root/data_bags"

environment_path "/chef-repo/environments/qa"

ssl_verify_mode :verify_none

node_path ["/chef-repo/nodes"]
file_staging_uses_destdir true
http_proxy nil
http_proxy_user nil
http_proxy_pass nil
https_proxy nil
https_proxy_user nil
https_proxy_pass nil
no_proxy nil


