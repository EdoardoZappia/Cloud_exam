# **Cloud Storage Deployment on Kubernetes**

This directory contains the solution for the **Cloud Advanced** assignment, which involves deploying a cloud storage solution on a single-node `Kubernetes` cluster. The deployment includes a [Nextcloud](https://nextcloud.com/) instance integrated with `PostgreSQL` for data management and `Redis` for caching.

## **Directory Overview**

The folder is structured as follows:

```bash
.
├── README.md                   # This file
├── deploy_nextcloud.sh          # Script to deploy Nextcloud
├── initial_setup.sh             # Script to initialize the Kubernetes cluster
└── nextcloud                    # Directory for Nextcloud manifests and configuration
    ├── metallb/                 # Manifests for MetalLB configuration
    │   ├── configmap.yaml
    │   ├── ipaddresspool.yaml
    │   └── l2advertisement.yaml
    ├── secrets/                 # Secrets for Nextcloud, PostgreSQL, and Redis
    │   ├── nextcloud-postgresql-secrets.yaml
    │   ├── nextcloud-redis-secrets.yaml
    │   └── nextcloud-secrets.yaml
    ├── values.yaml              # Helm values for customized Nextcloud setup
    └── volumes/                 # Persistent Volume configurations
        ├── nextcloud-postgresql-pv.yaml
        ├── nextcloud-postgresql-pvc.yaml
        ├── nextcloud-pv.yaml
        └── nextcloud-pvc.yaml
```

## **Deployment Guide**

### **1. Setting Up the Virtual Machine**

Begin by creating a virtual machine (VM) that will host the Kubernetes cluster. Follow these steps:

1. **VM Installation**:
   - Download and install a suitable OS image such as Fedora 39.
   - For virtualization, tools like `UTM` (on macOS) or `VirtualBox` (on other systems) can be used.
   - Configure the VM with a minimum of 2 CPUs and 2GB of RAM.
   - Ensure SSH access is enabled for root to simplify remote management.

2. **Kubernetes Cluster Setup**:
   - Execute the `initial_setup.sh` script on the VM to set up Kubernetes and the necessary components.
   - This script handles network configuration, ingress controller setup, and MetalLB for load balancing.

### **2. Deploying Nextcloud**

Once the Kubernetes cluster is operational, you can deploy the Nextcloud instance using Helm and the provided configuration.

1. **Setup**:
   - Copy the `nextcloud` directory into the `/root/home` directory on the VM. If you prefer a different location, modify the paths in the scripts accordingly.

2. **Deploy Nextcloud**:
   - Run the `deploy_nextcloud.sh` script. This will install Nextcloud via Helm using the settings defined in the `values.yaml` file.
   - The script also configures persistent volumes, secrets, and MetalLB to assign an external IP to the Nextcloud service.

3. **Confirm Deployment**:
   - Check that all services are running correctly by executing:

   ```bash
   kubectl get svc -n nextcloud
   ```

   You should see a LoadBalancer service with an external IP provided by MetalLB.

### **3. Accessing Nextcloud**

You can access the Nextcloud web interface from your host machine by setting up port forwarding.

1. **Port Forward Setup**:
   - Use `tmux` to manage the port forwarding on the VM:

   ```bash
   tmux new-session -d -s nextcloud-portforward "kubectl port-forward service/nextcloud-advanced 8080:8080 --address 0.0.0.0 -n nextcloud"
   ```

2. **Local Forwarding**:
   - On your host machine, use SSH to forward the VM's port to your local system:

   ```bash
   ssh user@<VM_IP> -L 8080:localhost:8080
   ```

3. **Open Nextcloud**:
   - Open a browser and go to `http://localhost:8080`.
   - The Nextcloud login page will be displayed, allowing you to create an account and begin using the service.
