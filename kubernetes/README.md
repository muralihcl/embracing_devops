# Kubernetes v1.29 Installation with cri-o container runtime - Multi Node Cluster setup


```console
Step 1 : Create 3 VMs with Ubuntu 22.04 LTS OS. VM1: k8s-n1 (192.168.56.35), VM2: k8s-n2 (192.168.56.36), VM3: k82-n3 (192.168.56.37)

$$ On all three nodes - perform below steps
Step 2 : Regenerate machine-id and OpenSSH Host keys. Update /etc/hosts file to include hosts table
Step 3 : Perform pre-requisite configuration before Kubernetes installation
Step 4 : Install Cri-O container runtime using apt package manager and install crictl binary
Step 5 : Install specific version of kubelet, kubectl and kubeadm

## Control Plane steps (k8s-n1)
Step 6 : Run kubeadm init and setup the control plane

$$ On k8s-n2 and k8s-n3 - perform below steps
Step 7 : Run kubeadm join command

```
# On k8s-n1, k8s-n2 & k8s-n3 : Until step 6

## Step 2 : Regenerate machine-id and OpenSSH host keys

```console
Step a : Delete the file /etc/machine-id and recreate it
Step b : Clean up the existing SSH Host keys and regenerate them
Step c : Restart the VMs
```
When we create VMs from cloning or restoring an OVA template, there is high chance that all the VMs get same machine-id and SSH host keys, hence it becomes necessary to make all of them unique.

## Step a : Delete the file /etc/machine-id and recreate it

```bash
$ sudo rm -f /etc/machine-id
$ sudo systemd-machine-id-setup
```
## Step b : Clean up the existing SSH Host keys and regenerate them. Update /etc/hosts file to include hosts table.

```bash
$ sudo rm -v /etc/ssh/ssh_host_*
$ sudo dpkg-reconfigure openssh-server

$ cat <<EOF | sudo tee -a /etc/hosts
192.168.56.35   k8s-n1.example.com  k8s-n1
192.168.56.36   k8s-n2.example.com  k8s-n2
192.168.56.37   k8s-n3.example.com  k8s-n3
EOF

```

## Step c : Reboot the VMs

```bash
$ sudo reboot
```

## Step 3 : Perform pre-requisite configuration before Kubernetes installation

```console
Step a : Enable overlay and br_netfilter kernel modules to load automatically
Step b : Configure ipforward rules
Step c : Disable swap and delete the fstab entry
Step d : Install pre-requisite packages
```
These pre-requisite configurations are critical for establishing a properly built kubernetes cluster and to maintain inter service communication with ease.

## Step a : Enable overlay and br_netfilter kernel modules to load automatically

```bash
$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

$ sudo modprobe overlay
$ sudo modprobe br_netfilter
```
Verify the kernel modules are loaded properly

```bash
$ sudo lsmod | egrep 'overlay|br_netfilter'
```

## Step b : Configure ipforward rules

```bash
$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

$ sudo sysctl --system
```

## Step c : Disable swap and delete the fstab entry

```bash
$ sudo swapon -s
$ sudo swapoff -a
$ sudo sed -i '/swap/d' /etc/fstab
$ sudo swapon -s
```

## Step d : Install pre-requisite packages

```bash
$ sudo apt update -y
$ sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates
```
## Step 4 : Install Cri-O container runtime using apt package manager and install crictl binary

```console
Step a : Import Cri-O gpg key and configure cri-o repository
Step b : Install Cri-O and start and enable cri-o service
Step c : Install crictl utility
```
Kubernetes needs a reliable container runtime. For a long time, docker has been a defacto standard for the container runtime. But, slowly lots of players started utilizing cri-o or containerd instead of docker. In this example, we'll be utilizing cri-o as the container runtime.

## Step a : Import Cri-O gpg key and configure cri-o repository

```bash
$ curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
$ echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list
```
## Step b : Install Cri-O and start and enable cri-o service

One might need to assess the required version of tools in future to confirm which version works well with a specific version of cri-o container runtime. With this example, we are using crictl version 1.28.0

```bash
$ sudo apt-get update -y
$ sudo apt-get install -y cri-o
$ sudo systemctl daemon-reload
$ sudo systemctl enable crio --now
$ sudo systemctl status crio
```

## Step c : Install crictl utility

```bash
$ CRICTL_VERSION="v1.28.0"
$ wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
$ sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
$ rm -f crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
```

## Step 5 : Install specific version of kubelet, kubectl and kubeadm

```console
Step a : Import Kubernetes repo gpg key and enable specific version of repo
Step b : Install kubelet, kubectl and kubeadm packages using apt
Step c : Ensure kubelet service is enabled and started
Step d : Reboot the VMs
```
As on date, we are using the n-1 release of kubernetes with this example. Future version of kubernetes might need some re-writes.

## Step a : Import Kubernetes repo gpg key and enable specific version of repo

Creation of /etc/apt/keyrings might be needed in most of the recent version of kubernetes. No harm in getting it created as part of the steps.

```bash
$ K8S_VERSION=1.29
$ sudo mkdir -p /etc/apt/keyrings
$ curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | $ sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
$ echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update -y
```

## Step b : Install kubelet, kubectl and kubeadm packages using apt

```bash
$ sudo apt-cache madison kubeadm | tac
```

The above command gives the list of latest version of the kubernetes packages. From our list, we went ahead with the latest one, 1.29.4-2.1. The apt-mark hold command saves accidental upgrade of kubelet, kubeadm and kubectl packages.

```bash
$ sudo apt-get install -y kubelet=1.29.4-2.1 kubectl=1.29.4-2.1 kubeadm=1.29.4-2.1
$ sudo apt-mark hold kubelet kubeadm kubectl
```

Install jq package to that can be used to pick the local IP address assigned to the private host-only interface. In our case, enp0s8. Including the KUBELET_EXTRA_ARGS with the node IP matching the hosts help limit the communication to the private interface.

```bash
$ sudo apt-get install -y jq
$ local_ip=$(ip --json addr show enp0s8 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')
$ echo "KUBELET_EXTRA_ARGS=--node-ip=${local_ip}" | sudo tee -a /etc/default/kubelet
```

## Step c : Ensure kubelet service is enabled and started

```bash
$ sudo systemctl status kubelet
```

If needed, restart the kubelet service.

```bash
$ sudo systemctl restart kubelet
```

## Step d : Reboot the VMs

```bash
$ sudo reboot
```

## Step 6 : Run kubeadm init and setup the control plane (k8s-n1)

With all the platform set, now we are ready to initialize the kubeadm cluster.

```bash
$ sudo kubeadm init --apiserver-advertise-address=192.168.56.35 \
    --apiserver-cert-extra-sans=192.168.56.35 \
    --pod-network-cidr=172.16.0.0/16 --node-name k8s-n1.example.com
```
Configure the kube config file as displayed at the end of the kubeadm init command.

```bash
$ mkdir -p ${HOME}/.kube
$ sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
$ sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
```

Once the cluster is setup, use the kubeadm join command displayed at the end of the kubeadm init command and run the command on k8s-n2 and k8s-n3.

If the join command is not recorded, the same can be retrieved using below command.

```bash
$ kubeadm token create --print-join-command
```

## Step 7: Run kubeadm join command (k8s-n2 and k8s-n3)

```bash
$ sudo kubeadm join 192.168.56.35:6443 --token u556y2.lcscuxjyc2h4mj0o \
    --discovery-token-ca-cert-hash sha256:b6964985864ab87caca55ecabc0f95a1b4137e9e0e9f3229749dad09f39fa561
```

Validate if all the nodes are able to be listed.

```bash
$ kubectl get nodes -o wide
```

#### This completes the installation of kubernetes cluster with kubadm.
