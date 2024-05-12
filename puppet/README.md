# Puppet specific instructions
This README contains instructions related to the puppet configuration management tool

## Setup hostname for both server and the client

```bash
$ sudo hostnamectl set-hostname ubs-puppet.example.com (server)
$ sudo hostnamectl set-hostname ubs-node1.example.com (client)
$ sudo vim /etc/hosts (Add below lines of entries at the end)
192.168.56.33   ubs-puppet.example.com  puppet.example.com  ubs-puppet  puppet
192.168.56.38   ubs-node1.example.com   ubs-node1
```
Reboot the server and the client

## Install puppetserver on Ubuntu 22.04 Server

```bash
$ wget https://apt.puppetlabs.com/puppet8-release-jammy.deb
$ sudo dpkg -i puppet8-release-jammy.deb
$ sudo apt update
$ sudo apt install puppetserver
```
## Update the Java Args

```bash
$ sudo vim /etc/default/puppetserver
JAVA_ARGS="-Xms1g -Xmx1g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"

$ sudo systemctl start puppetserver
$ sudo systemctl enable puppetserver
$ sudo systemctl status puppetserver
``` 

## Update the default puppet configuration

```bash
$ sudo vim /etc/puppetlabs/puppet/puppet.conf

# add to the end
dns_alt_names = ubs-puppet.example.com,puppet.example.com,ubs-puppet,puppet
# Provide any [environment] name
environment = production

[main]
certname = ubs-puppet.example.com
server = ubs-puppet.example.com
```
## Install Puppet agent on the client and update the puppet.conf file

```bash
$ wget https://apt.puppetlabs.com/puppet8-release-jammy.deb
$ sudo dpkg -i puppet8-release-jammy.deb
$ sudo apt update
$ sudo apt install puppet-agent
$ sudo vim /etc/puppetlabs/puppet/puppet.conf

[main]
certname = ubs-node1.example.com
server = ubs-puppet.example.com

$ sudo systemctl start puppet
$ sudo systemctl enable puppet
$ sudo systemctl status puppet

```

## Sign the certificate request generated from the client

Logout the session and sudo to the root. Usually, the puppet binary path will be updated for root user. Depending on the version, it can be /opt/puppetlabs/bin or /opt/puppetlabs/server/bin.

```bash
$ sudo puppetserver ca list --all
$ sudo puppetserver ca sign --certname ubs-node1.example.com (sign the certificate for one node)
$ sudo puppetserver ca sign --all (sign all the signing requests waiting to be signed)

```

We can also configure puppet to automatically accept signing request from different filters. One of the widest filter is '*' meaning, accept all incoming certificate requests.

## Puppet manifests
Just like ansible works with the playbooks, puppet uses manifests to apply the configuration onto the clients. The major difference being requirement of an agent to be installed on the client. One of the predominent use cases with this approach is, automted server deployment done via Puppet would not need any requests to be initiated from the server. Instead, when a puppet agent service is started and pre-defined auto signing is in place, a server getting deployed can be made to receive necessary configuration without even needing any server side intervention.

```bash
$ sudo mkdir -p /etc/puppetlabs/code/environments/{dev,test,uat,qa,production}/manifests (where environment can be dev, test, uat, qa, production etc)
$ sudo vim /etc/puppetlabs/code/environments/production/manifests/site.pp

user { 'user1':
    ensure   => 'present',
    uid      => 1001,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
}

user { 'user2':
    ensure   => 'present',
    uid      => 1002,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
}

group { 'common':
    ensure   => 'present',
    gid      => 2000,
}
```

The above mentioned site.pp has all the instructions applied to all the hosts that are reaching the puppet server for configurations. Though we have kept group creation at the end, puppet compiles the catalog for a client in such a way that the dependent tasks are run first and next layer of tasks shall get executed. In the example above, the group creation happens first and users shall get created next.

Puppet works with resource types. The basic syntax of the manifests are like this. Considering this, in the above site.pp example, we can clearly say that user and group are the resource types with respective resource names and arguments/parameters that are to be supplied while creating a user or a group.

```bash
resource_type { 'resource_name':
    argument1 => 'value1',
    argument2 => 'value2',
    argument3 => 'value3'
}
```

To know the syntax, in case there is no way to connect to the internet, we can run below commands to get the syntax displayed on the screen. At the same time, they can be redirected to another .pp(puppet program) file which then can be placed inside the manifests directory.

```bash
$ sudo puppet resource package nginx > nginx.pp
$ sudo puppet resource user user1 > user.pp
```

## Creating modules for individual tasks

The directory /etc/puppetlabs/code/environments/production/ contains manifests and modules directory, which is specific to the production environment. However, there is another modules folder under /etc/puppetlabs/code/ folder. The modules defined in this path are accessible to all the environments.

The easiest option to get a module is to install it from puppet forge.

```bash
$ sudo puppet module install puppetlabs-apache
```

However, if installation cannot be done and if we need to create custom modules by ourselves, all we need to create is a directory structure under respective modules directory (module_name/manifests). The module_name/manifests folder should contain the init.pp special file that would declare a class and defines any interoperability between the init.pp and any other .pp files inside the module_name/manifests folder.

The original site.pp file to create a group, create 2 users and install a package can be written like this.

```bash
user { 'user1':
    ensure   => 'present',
    uid      => 1001,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
}

user { 'user2':
    ensure   => 'present',
    uid      => 1002,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
}

group { 'common':
    ensure   => 'present',
    gid      => 2000,
}

package { 'nginx':
    ensure   => 'present'
}
```

If the same logic is modularized, it would look similar to this.

The node definition within the site.pp ensures a specific block of code is applied to specific hosts or a pattern of hosts or comma separate hosts. The node default section is something that will be applicable to all the hosts that are not part of the updated node definitions. We are including the action that are part of two modules called create_user and install_nginx. We can also specify any sub classes using :: sepration. For example, create_user has user and group .pp files inside the module manifests folder. If we only need to use create_user::user, we'll only get the create_user::user functionality.

```bash
node 'ubs-node1.example.com' {
  include create_user
  include install_nginx
}

node default {

}
```

The environments/production/modules/create_user/manifests folder should have init.pp that looks like this. With this init.pp, we are declaring a class create_user and the class contains sub classes create_user::user and create_user::group. We can also specify in what order the classes need to be executed. In the below example, we are defining create_user::group should be run first and then create_user::user.

```bash
class create_user (
) {
  contain 'create_user::group'
  contain 'create_user::user'
  Class['create_user::group'] -> Class['create_user::user']
}
```

The sub classes are nothing but other .pp files (user.pp to have create_user::user class defined and group.pp to have create_user::group class defined.)

environments/production/modules/create_user/manifests/user.pp

```bash
class create_user::user {
  user { 'user1':
    ensure   => 'present',
    uid      => 1001,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
  }
  
  user { 'user2':
    ensure     => 'present',
    uid        => 1002,
    gid        => 2000,
    comment    => 'User created via puppet',
    managehome => true,
    password   => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
  }
}
```

environments/production/modules/create_user/manifests/group.pp

```bash
class create_user::group {
  group { 'common':
    ensure   => 'present',
    gid      => 2000,
  }
}

```

This should cover the instructions for modularizing the puppet codes.

**Note: One major downside of the Puppet is, there resources types are very limited in puppet. All the automations are to be dependent only on these limited resource types. While ansible comes out of the box with thousands of modules to cator various actions, puppet on the other hand emphesizes on using the limited resource types and building the automation around them.