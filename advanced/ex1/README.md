# **Deploying a Cloud Storage System on Kubernetes**

This guide provides the solution for the first **Cloud Advanced** assignment, outlining the steps to deploy a cloud-based file storage system using `Kubernetes` on a single-node cluster.

`initial_setup.sh`: loads modules, disables problematic stuff, installs Kubernetes, installs utils, install Helm and tmux

`deploy_nextcloud.sh`: 

## **Deployment Steps**

Remember to insert the correct IP addresses in `ipaddresspool.yaml`, in `nextcloud-postgresql.yaml` and in `nextcloud-pv.yaml`.

### **1. Virtual Machine Setup**

Start by setting up a virtual machine (VM) to host the Kubernetes cluster.

1. **Create a VM**:
   - Download the Fedora 39 server image or another preferred operating system.
   - Use a tool such as `UTM` (for macOS) or `VirtualBox` to create the VM.
   - Allocate at least 2 CPUs and 2GB of RAM to the VM.
   - Enable SSH access for the root user.

2. **Cluster Initialization**:
   - Copy the `initial_setup.sh` script to the VM:

   ```bash
   scp initial_setup.sh root@<VM_IP>:/root
   ```

   - Log in to the VM via SSH:

   ```bash
   ssh root@<VM_IP>
   ```

   - Run the `initial_setup.sh` script to set up Kubernetes and required components:

   ```bash
   ./initial_setup.sh
   ```

This script will install `Kubernetes`, `Helm` and other necessary components on the VM and set up the `Kubernetes` single-node cluster and all the required environment.

You can check the status of the cluster either with

``` bash

kubectl get nodes

```

You should see the single node of the cluster with the status `Ready`.

You can also check the status of the pods running in the cluster by running the following command:

``` bash

kubectl get pods --all-namespaces -o wide

```

### **2. Deploying Nextcloud**

Once the Kubernetes cluster is ready, proceed with deploying the Nextcloud instance.

1. **Prepare the Environment**:
   - Copy the `nextcloud` directory  and the `deploy_nextcloud.sh` script to the VM:

   ```bash

   scp deploy_nextcloud.sh root@<VM_IP>:/root/home

   scp -r nextcloud root@<VM_IP>:/root/home
   ```

   - Ensure that the directory paths in the deployment scripts match the location of the copied files.

2. **Run the Deployment Script**:
   - Execute the `deploy_nextcloud.sh` script to deploy Nextcloud using Helm and custom values from `values.yaml`:

   ```bash
   ./deploy_nextcloud.sh
   ```

   This script will configure persistent volumes, secrets, and assign an external IP address using MetalLB.

3. **Check Deployment Status**:
   - Verify that the services are running by executing:

   ```bash
   kubectl get svc -n nextcloud
   ```

   Ensure that a LoadBalancer service with an external IP is visible.

### **3. Accessing Nextcloud**

To access the Nextcloud interface from your local machine, you need to forward the ports.

1. **Port Forwarding on VM**:
   - Set up port forwarding using `tmux` to allow the Nextcloud service to be accessible:

   ```bash
   tmux new-session -d -s nextcloud-portforward "kubectl port-forward service/nextcloud-advanced 8080:8080 --address 0.0.0.0 -n nextcloud"
   ```

2. **Accessing Nextcloud from the Host Machine**:
   - On your host machine, forward the VM's port to your local machine using SSH:

   ```bash
   ssh user@<VM_IP> -L 8080:localhost:8080
   ```

   - Open a browser and navigate to `http://localhost:8080`.

3. **Nextcloud Login**:
   - The Nextcloud login page should load in your browser, where you can create a new account and start using the platform.
