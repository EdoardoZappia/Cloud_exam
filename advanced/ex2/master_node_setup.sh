#!/bin/bash

# Initialize kubernetes
kubeadm init --pod-network-cidr=10.17.0.0/16 --service-cidr=10.96.0.0/12 > /root/kubeinit.log

# Create a new file with the join command (to connect the worker nodes)
cat /root/kubeinit.log | grep -A 1 "kubeadm join" > /root/join_nodes.sh
chmod +777 /root/join_nodes.sh

# Copy the kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Enable access from other nodes
sudo cp /etc/kubernetes/admin.conf /home/admin.conf
sudo chmod 666 /home/admin.conf

# Remove taints from the master node
kubectl taint nodes ###.###.##.## node-role.kubernetes.io/control-plane-

# Disable the firewall
systemctl stop firewalld
systemctl disable firewalld

# Credentials for non-root users
cd /home
mkdir -p .kube
sudo cp /home/admin.conf .kube/config
sudo chown $(id -u):$(id -g) .kube/config

# Go back to the root directory
cd

# Change the default registry (fedora) to docker.io
cat << EOF | tee /etc/containers/registries.conf
[registries.search]
registries = ['docker.io']
EOF

# Build the images we need, by going to the directory with the Dockerfiles
cd /home/Dockerfiles_MPI_OSU
# Create a builder image for OpenMPI
podman build -f openmpi-builder.Dockerfile -t openmpi-builder
# Create the image with the source code for the OSU benchmarks
podman build -f osu-code-provider.Dockerfile -t osu-code-provider
# Create the OpenMPI image
podman build -f openmpi.Dockerfile -t openmpi
# Create the final pod with the OSU benchmarks
podman build -t osu-benchmark .
