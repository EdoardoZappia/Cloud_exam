#!/bin/bash

# This script is intended to be run on both nodes of the cluster (both the virtual machines) to prepare the environment
# It will install the necessary packages and configure the system

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

# disable zram
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
# Real kube
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# Install CRI-o, podman, docker and helm
dnf install -y crio podman docker helm

# Enable and start the services
sed -i 's/10.85.0.0\/16/10.17.0.0\/16/' /etc/cni/net.d/100-crio-bridge.conflist
systemctl enable --now crio
systemctl enable --now kubelet
systemctl enable --now docker

# Install k9s
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

# Install the CNI plugin (container networking interface)
sudo mkdir -p /opt/cni/bin
sudo curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.2.0.tgz
