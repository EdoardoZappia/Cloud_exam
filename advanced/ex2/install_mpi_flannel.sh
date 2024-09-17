#!/bin/bash

# This script is intended to be run on the master node of the cluster to install MPI and flannel

# Enter the home directory
cd /home

# Install the MPI operator
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/master/deploy/v2beta1/mpi-operator.yaml

# Install flannel
export pod_network_cidr=10.17.0.0/16 # This is the same as the one used in kubeadm init
kubectl create namespace kube-flannel # Create the flannel namespace
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged # Label the namespace
# Add the flannel helm repository
helm repo add flannel https://flannel-io.github.io/flannel/
# Update the helm repositories
helm repo update
# Install flannel
helm install flannel --set podCidr="$pod_network_cidr" flannel/flannel -n kube-flannel
