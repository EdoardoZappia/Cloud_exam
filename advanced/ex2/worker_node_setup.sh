#!/bin/bash

# This script is intended to be run on the worker nodes of the cluster to prepare their environment

export master_ip=192.168.64.23 # Change this to the IP of the master node

# Copy the credentials from the master node
scp -o stricthostkeychecking=no root@$master_ip:/home/admin.conf /home/admin.conf

# Copy the kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /home/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Disable the firewall
systemctl stop firewalld
systemctl disable firewalld

# Join the node to the cluster (use the join_nodes.sh script created by the master node)
scp -o StrictHostKeyChecking=no root@$master_ip:/root/join_nodes.sh /root
/root/join_nodes.sh

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
