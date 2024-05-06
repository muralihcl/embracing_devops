# Ansible specific instructions
This README contains instructions related to the ansible exercises

## Install Ansible on Ubuntu 22.04 Server

Ansible can be installed using the package manager apt or pip package manager inside a python virtual environment.

Installation with package manager (needs sudo privileges)

```bash
$ sudo apt update -y
$ sudo apt install ansible
$ ansible --version
```

Installation with pip package manager. Pre-requisites for this are python3-pip and python3-virtualenv packages. If they are not installed, need that to be installed. However, there are portable virtual environments that can be downloaded and used as well, without needing to have any escalated privileges.

```bash
$ python3 -m venv virtualenv
$ source virtualenv/bin/activate
(virtualenv) $ pip install --upgrade pip setuptools
(virtualenv) $ pip install ansible
(virtualenv) $ ansible --version
```

## Check if Ansible installation is successful

We can run an ad-hoc command to retrieve the localhost ansible facts as shown belolw. This will display all the retrievable configuration information of the localhost.

```bash
(virtualenv) $ ansible -m setup localhost
``` 

Executing the playbook

```bash
(virtualenv) $ cd playbooks
(virtualenv) $ ansible-playbook k8s_playbook.yml
```
