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

vagrant/rocky9/Vagrantfile (This contains instructions to create autouser and enable password based authentication)

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
```
