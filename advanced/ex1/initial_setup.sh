#!/bin/bash

# Load modules for container runtime
modprobe overlay
modprobe br_netfilter

# Make the load permanent
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Change the kernel parameters
cat <<EOF |  tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Load kernel parameters at runtime
sysctl --system

# disable zram and swap for k8s (they could be a problem for the pod resource menagement)
touch /etc/systemd/zram-generator.conf
swapoff -a

# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Kubernetes
cat << EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Some utils
dnf install iproute-tc wget vim bash-completion bat -y
# CRI-o (container runtime)
dnf install crio -y
# Kubernetes components
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start the services
sed -i 's/10.85.0.0\/16/10.17.0.0\/16/' /etc/cni/net.d/100-crio-bridge.conflist
systemctl enable --now crio
systemctl enable --now kubelet

# Initialize the cluster (cidr is the pod network)
kubeadm init --pod-network-cidr=10.17.0.0/16  

# Copy the kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

alias k=kubectl

# Install k9s (it simplifies the debugging)
cd /tmp
wget https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
chmod +x k9s
mv k9s /usr/local/bin
export EDITOR=vim
cd ~

cat << EOF | tee -a ~./basrc
echo EDITOR=vim
alias k=kubectl
source < (kubectl completion bash)
EOF

# Install Helm
dnf install -y helm

# Remove the taint (to allow the pods to run on the master node)
kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

# Create directories for the persistent volumes
mkdir -p /home/volumes
mkdir -p /home/volumes/nextcloud
mkdir -p /home/volumes/postgresql

# Install tmux (to do the port forwarding to access the service from the host machine web browser)
dnf install -y tmux
