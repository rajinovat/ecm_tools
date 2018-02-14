local_mode      :true
chef_repo_path  "/chef-repo/"
ssl_verify_mode :verify_none
file_staging_uses_destdir false
cookbook_path ["/chef-repo/cookbooks"]
role_path "/chef-repo/roles"
environment_path "/chef-repo/environments/test"