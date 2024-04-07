# Vagrant specific instructions
This folder contains files that are used during vagrant exercises.


## Utilize the Vagrantfile examples
(Assuming the Vagrant utulity is installed, github repository is cloned and we are inside the docker directory)

rocky9/Vagrantfile (This contains instructions to create autouser and enable password based authentication, hence one can also connect to the private IP address via SSH)

```
cd rocky9
vagrant up
vagrant ssh
```

ubuntu_focal/Vagrantfile (Slightly customized Vagrantfile, but can only allow to connect through key based authentication using ```vagrant ssh```)
```
cd ubuntu_focal
vagrant up
vagrant ssh
```

trusty/Vagrantfile (Default Vagrantfile created using ```vagrant init ubuntu/trusty64```)
```
cd trusty
vagrant up
vagrant ssh
```

Some common commands to try with vagrant

```vagrant global-status``` Displays the vagrant environments available across the system.

```vagrant box add ubuntu/focal64``` Download the ubuntu/focal64 box (image). (If the box does not exist, when ```vagrant up``` command is executed, the box will automatically get downloaded)

```vagrant box list``` List the vagrant boxes available in the system.

```vagrant init ubuntu/focal64``` Initialize/create a default Vagrantfile in the current directory with ubuntu/folcal64 as the box name.

