# Embracing DevOps code repository
This repository would contain all codes that are consumed during the Embracing DevOps training

| Folder Name | Description                                                    |
| ------------------------- | ------------------------------------------------ |
| vagrant     | This directory contains the files used during vagrant sessions |
| docker      | This directory contains the files used during docker sessions |
| kubernetes  | This directory contains the files used during kubernetes sessions |
| ansible     | This directory contains the files used during ansible sessions |
| puppet      | This directory contains the files used during puppet sessions |
| chef        | This directory contains the files used during chef sessions |
| terraform   | This directory contains the files used during terraform sessions |

## Utilize the Vagrantfile examples
(Assuming the github repository is cloned and we are inside the created directory)

vagrant/rocky9/Vagrantfile (This contains instructions to create autouser and enable password based authentication, hence one can also connect to the private IP address via SSH)

```
cd vagrant/rocky9
vagrant up
vagrant ssh
```

vagrant/ubuntu_focal/Vagrantfile (Slightly customized Vagrantfile, but can only allow to connect through key based authentication using ```vagrant ssh```)
```
cd vagrant/ubuntu_focal
vagrant up
vagrant ssh
```

vagrant/trusty/Vagrantfile (Default Vagrantfile created using ```vagrant init ubuntu/trusty64```)
```
cd vagrant/trusty
vagrant up
vagrant ssh
```

Some common commands to try with vagrant

```vagrant global-status``` Displays the vagrant environments available across the system.

```vagrant box add ubuntu/focal64``` Download the ubuntu/focal64 box (image). (If the box does not exist, when ```vagrant up``` command is executed, the box will automatically get downloaded)

```vagrant box list``` List the vagrant boxes available in the system.

```vagrant init ubuntu/focal64``` Initialize/create a default Vagrantfile in the current directory with ubuntu/folcal64 as the box name.

