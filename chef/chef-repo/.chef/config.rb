current_dir = File.dirname(__FILE__)
log_level :info
log_location STDOUT
node_name 'ubs-chef'
client_key "chefadmin.pem"
validation_client_name 'mkoptima-validator'
validation_key "mkoptima-validator.pem"
chef_server_url 'https://ubs-chef.example.com/organizations/mkoptima'
cache_type 'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path ["#{current_dir}/../cookbooks"]
