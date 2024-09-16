
# Cloud-Based File Storage System with Nextcloud on Kubernetes

This repository contains the configuration files and instructions for deploying a cloud-based file storage system using **Nextcloud** on **Kubernetes**, integrated with **PostgreSQL** as the database backend, **Redis** for caching, and **MetalLB** for load balancing.

## Table of Contents

- [Introduction](#introduction)
- [Setup Requirements](#setup-requirements)
- [Preliminary Setup](#preliminary-setup)
- [Cluster Setup](#cluster-setup)
- [Nextcloud Deployment](#nextcloud-deployment)
- [Ingress Configuration](#ingress-configuration)
- [Accessing the Cloud Service](#accessing-the-cloud-service)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

## Introduction

In this project, we will walk through the process of setting up **Nextcloud** on a Kubernetes cluster, along with **PostgreSQL**, **Redis**, and **MetalLB**. **Nextcloud** provides cloud-based file storage capabilities, and this deployment is designed for a self-hosted environment using local infrastructure.

## Setup Requirements

Before starting the setup, ensure you have the following:

- **UTM** installed with **Ubuntu** running as the virtual machine.
- **K3s** installed for lightweight Kubernetes setup.
- SSH tunnel for communication between your host machine and the Ubuntu VM.
- **Helm** for package management in Kubernetes.
- **kubectl** installed to interact with the cluster.

## Preliminary Setup

### 1. Setting up UTM with Ubuntu

To create a Kubernetes cluster, we are using **UTM** with an **Ubuntu** virtual machine. Follow the steps below to set up:

1. Download and install **UTM** from the official website.
2. Create a new virtual machine and install **Ubuntu**.
3. Ensure your VM has enough resources (e.g., at least 2 GB of RAM, 2 CPUs) for Kubernetes to function smoothly.

### 2. Creating an SSH Tunnel

Once your Ubuntu VM is up and running, you will want to create an SSH tunnel to interact with it from your host machine. This allows for easier control and management of the cluster.

1. Find the IP address of your Ubuntu VM using:

   ```bash
   ip a
   ```

2. From your host machine (e.g., Mac), open a terminal and create an SSH connection:

   ```bash
   ssh <username>@<VM-IP>
   ```

   Replace `<username>` with your Ubuntu username and `<VM-IP>` with the IP address of the VM.

## Cluster Setup

### 1. Install K3s

To set up Kubernetes, we use **K3s**, a lightweight Kubernetes distribution. Here's how to install and run K3s:

1. SSH into your Ubuntu VM and run the following command to install K3s:

   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

2. After installation, ensure the `kubectl` configuration is correctly set by exporting the path:

   ```bash
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   ```

3. Verify that K3s is running by checking the node status:

   ```bash
   kubectl get nodes
   ```

### 2. Create the Kubernetes Namespace

Once K3s is up and running, create a dedicated namespace for **Nextcloud** to ensure isolation of resources:

```bash
kubectl create namespace nextcloud
```

## Nextcloud Deployment

### 1. Install Helm

Nextcloud and its components are deployed using **Helm** charts. First, install Helm:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2. Deploy Nextcloud, PostgreSQL, and Redis

1. Prepare your values file for configuration and secrets to store passwords securely.
2. Deploy **Nextcloud** using Helm:

   ```bash
   helm install nextcloud nextcloud/nextcloud --namespace nextcloud -f values.yaml
   ```

   This command will deploy **Nextcloud**, along with **PostgreSQL** and **Redis**, into the `nextcloud` namespace.

## Ingress Configuration

Once Nextcloud is deployed, you need to configure **Ingress** to expose the application to the network.

1. Apply the Ingress configuration using:

   ```bash
   kubectl apply -f ingress.yaml --namespace nextcloud
   ```

2. For environments that do not have cloud-based load balancers, we integrate **MetalLB** for IP address management and load balancing.

### 3. Configure MetalLB and L2Advertisement

1. Install the MetalLB CRDs:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/crd/bases/metallb.io_ipaddresspools.yaml
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/crd/bases/metallb.io_l2advertisements.yaml
   ```

2. The L2Advertisement resource is used to enable Layer 2 load balancing, which advertises an IP range on your local network. This allows the service to be reachable from external devices.

3. Apply the MetalLB configuration to manage IP addresses:

   ```bash
   kubectl apply -f metallb.yaml
   ```

## Accessing the Cloud Service

Once the deployment is complete, you can access the **Nextcloud** service using your browser:

1. If you're working locally, **Nextcloud** can be accessed via the IP assigned by **MetalLB** or using `localhost` through an SSH tunnel.
   
2. Check the external IP of the service:

   ```bash
   kubectl get svc --namespace nextcloud
   ```

   You will see the **Nextcloud** service with an assigned IP.

3. In your browser, navigate to `http://localhost` or the external IP to access the cloud service.

## Monitoring and Troubleshooting

### Monitoring Pods

To monitor the state of the pods and services, use the following commands:

- Check the status of the pods:

  ```bash
  kubectl get pods --namespace nextcloud
  ```

- View logs for any issues:

  ```bash
  kubectl logs <pod-name> --namespace nextcloud
  ```

### Restart Nextcloud Deployment

If there is any issue with the Nextcloud pods, you can restart the deployment:

```bash
kubectl rollout restart deployment nextcloud --namespace nextcloud
```

If there are network issues, ensure **MetalLB** is functioning properly by checking the services for an assigned external IP:

```bash
kubectl get svc --namespace nextcloud
```

---

This guide provides all the necessary steps to set up a cloud-based file storage system using Nextcloud on Kubernetes. The repository contains the essential configuration files (`values.yaml`, `ingress.yaml`, `secrets.yaml`, `metallb.yaml`, `persistent-volume.yaml` containing als pvc) that must be adapted according to your environment.
