# Chef specific instructions
This README contains instructions related to the Chef configuration management tool

## Setup hostname for both server and the client

```bash
$ sudo hostnamectl set-hostname ubs-chef.example.com (server)
$ sudo hostnamectl set-hostname ubs-minion.example.com (client)
$ sudo vim /etc/hosts (Add below lines of entries at the end)
192.168.56.33   ubs-chef.example.com  ubs-chef
192.168.56.38   ubs-minion.example.com   ubs-minion
```
Reboot the server and the client

## Install Chef infra server on Ubuntu 22.04 Server and perform first reconfiguration

```bash
$ wget https://packages.chef.io/files/stable/chef-server/15.9.27/ubuntu/18.04/chef-server-core_15.9.27-1_amd64.deb
$ sudo dpkg -i chef-server-core_15.9.27-1_amd64.deb
$ sudo chef-server-ctl reconfigure

```
## Create the directory structure and create a new user along with a pem file to authenticate

```bash
$ mkdir chef-repo/.chef -p
$ sudo chef-server-ctl user-create chefadmin Chef Admin chefadmin@example.com 'password' --filename chef-repo/.chef/chefadmin.pem
``` 

## Create an organization and associate the user with the organization

```bash
$ sudo chef-server-ctl org-create mkoptima 'MKOptima InnoSolutions' --association_user chefadmin --filename chef-repo/.chef/mkoptima-validator.pem
```
## Install chef-manage, a web server that can help to manage Chef Infra Server using a web browser

```bash
$ sudo chef-server-ctl install chef-manage
$ sudo chef-server-ctl reconfigure

```

## Install Chef Workstation and configure knife access

Chef workstation is the component of the Chef Infra tools which is responsible for creating and publishing the cookbooks. This is the node from where one can initiate client bootstrapping. It is not mandatory to configure Chef-workstation on the Chef Infra Server itself. It can also be done on another server if someone wishes to do so. However, the certificates created during above steps are to be copied over to the other host for workstation to work from a remote host.

```bash
$ wget https://packages.chef.io/files/stable/chef-workstation/24.4.1064/debian/10/chef-workstation_24.4.1064-1_amd64.deb
$ sudo dpkg -i chef-workstation_24.4.1064-1_amd64.deb
$ vim chef-repo/.chef/config.rb (The critical pieces here are node_name, client_key, validation_client_name, validation_key and chef_server_url)

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

```

Test the workstation to the server connectivity and bootstrap the server and the client.

```bash
cd ~/chef-repo
$ knife ssl fetch
$ knife ssl check
$ knife bootstrap ubs-chef.example.com -x root -P 'Password@123' --node-name ubs-chef
$ knife bootstrap ubs-minion.example.com -x root -P 'Password@123' --node-name ubs-minion
$ knife node list
```

Note: Knife is the tool used for managing various Chef related activities.

## Chef cookbooks

Just like ansible works with the playbooks, Chef uses the cookbooks to apply the configuration onto the clients. The major difference being requirement of an agent to be installed on the client. Like puppet, Chef client also can initiate the configuration sync from the client side itself without even needing any server side intervention.

From the chef-repo folder, we can create a cookbooks folder that can have all the cookbooks.

```bash
$ cd chef-repo/cookbooks (create the cookbooks directory if needed)
$ chef generate cookbook my_cookbook
$ vim my_cookbook/recipes/default.rb

group 'common' do
  comment      'Group created by Chef'
  gid          2000
  group_name   'common'
  action       :create
end

user 'user1' do
  comment      'User1 created by chef'
  uid          1001
  gid          'common'
  home         '/home/user1'
  shell        '/bin/bash'
  password     '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
end

user 'user2' do
  comment      'User2 created by chef'
  uid          1002
  gid          'common'
  home         '/home/user2'
  shell        '/bin/bash'
  password     '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
end

```

Once the cookbooks are updated with the instructions, we can upload the cookbooks to the server and then update the run list of a node/client.

```bash
$ knife cookbook upload my_cookbook
$ export EDITOR=vi
$ knife node edit ubs-minion

{
  "name": "ubs-minion",
  "chef_environment": "_default",
  "normal": {
    "tags": []
  },
  "policy_name": null,
  "policy_group": null,
  "run_list": [
    "recipe[my_cookbook]"    (This is the line that would attach my_cookbook cookbook to the client ubs-minion)
  ]
}
```

Aftert this, if chef-client tool is run on the minion, it will apply the configuration needed to be applied on the minion.

```bash
$ sudo chef-client
```

## Modularizing the cookbooks

Instead of having everything defined in the recipes/default.rb file, the instructions could be distributed to other .rb files and the default.rb file can have references to the other files.

```bash
$ cat cookbooks/my_cookbook/recipes/user.rb

user 'user1' do
  comment      'User1 created by chef'
  uid          1001
  gid          'common'
  home         '/home/user1'
  shell        '/bin/bash'
  password     '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
end

user 'user2' do
  comment      'User2 created by chef'
  uid          1002
  gid          'common'
  home         '/home/user2'
  shell        '/bin/bash'
  password     '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
end

$ cat cookbooks/my_cookbook/recipes/group.rb

group 'common' do
  comment      'Group created by Chef'
  gid          2000
  group_name   'common'
  action       :create
end

$ cat cookbooks/my_cookbook/recipes/package.rb

package 'nginx' do
  action       :install
end

service 'nginx' do
  action       [ :enable, :start ]
end

$ cat cookbooks/my_cookbook/recipes/default.rb

include_recipe 'my_cookbook::group'
include_recipe 'my_cookbook::user'
include_recipe 'my_cookbook::package'

$ knife cookbook upload my_cookbook
```

After this procedure, we can run chef-client on the minion. Despite having modularized, the cookbook performs the same kind of steps on the chef client.

**Note: Chef has a tool called chef inspec. This tool is widely used for reporting purpose. Though the out of the box resources available on Chef are more than that of Puppet, Ansible beats both the configuration management tools with this. Though Ansible excels in lots of the utilities, puppet and chef have their own applicability and the customer base.
