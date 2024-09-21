# MPI Service Deployment on Kubernetes

This directory contains the solution for the second task of the **Cloud Advanced** assignment, which involves deploying and executing the [OSU benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) on a two-node `Kubernetes` cluster, with each container distributed across two separate nodes.

## Directory Overview

This is the list of the files with their functions, I suggest to read this before jumping in the deployment:

`common_initial_setup.sh`: loads modules, disables problematic stuff, installs Kubernetes, installs utils, installs CRI-o, Docker and Helm, starts the services, installs CNI.

`master_node_setup.sh`: initializes Kubernetes, disables problematic stuff, enables access.

`worker_node_setup.sh`: joins the node to the cluster.

`install_mpi_flannel.sh`: installs MPI operator and Flannel.

`Docketfile.txt`, `openmpi-builder.Dockerfile`, `openmpi.Dockerfile`, `osu-code-provider.Dockerfile`:  work together to build and provide an environment for compiling, running, and benchmarking applications using OpenMPI.

`latency_one_node.sh`: creates the necessary namespace (osu-benchmark) and output directory (Results), applies the `latency-one-node.yaml` MPI job to the cluster, waits for the benchmark pod to complete, retrieves the results, and writes them to `Results.txt` and cleans up the resources once the job is finished.

`latency_one_node.yaml`: defines an MPIJob that runs the OSU latency benchmark using MPI processes on a Kubernetes cluster, specifies the MPI launcher and worker pods, along with their configuration for running the benchmark, runs the osu_latency benchmark to measure communication latency between two MPI processes.

`latency_two_node.sh`, `latency_two_node.yaml`: do the same but on two nodes.

`scatter_one_node.sh`, `scatter_one_node.yaml`, `scatter_two_node.sh`, `scatter_two_node.yaml`: do the same but they run the osu_scatter benchmark.

`plot_results.ipynb`: plots the results.

## Setup Instructions

Remember to insert the IP address in `master_node_setup.sh`, `worker_node_setup.sh`

To deploy and execute the OSU benchmark, two virtual machines (VMs) must be created, each running `Kubernetes` with the necessary components, forming a two-node `Kubernetes` cluster.

### Virtual Machine Setup

   - Download the Fedora 39 server image or another preferred operating system.
   - Use a tool such as `UTM` (for macOS) or `VirtualBox` to create the VM.
   - Allocate at least 2 CPUs and 2GB of RAM to the VM.
   - Enable SSH access for the root user.

To connect to the VM via `SSH`, use the following command:

```bash
ssh root@<VM_IP>
```

### Initial Setup

Once logged in, copy the `common_initial_setup.sh` script to both VMs using the following command:

```bash
scp common_initial_setup.sh root@<VM_IP>:/root
```

Execute the script on both VMs to install `Kubernetes` and other required components. Next, copy the `Dockerfiles_MPI_OSU` directory to both VMs:

```bash
scp -r Dockerfiles_MPI_OSU root@<VM_IP>:/root/home
```

### Master Node Configuration

Designate one of the VMs as the master node. Copy the `master_node_setup.sh` script to the master node and execute it to configure the `Kubernetes` master and build the OSU benchmark container:

```bash
scp master_node_setup.sh root@<VM_IP>:/root
```

```bash
./master_node_setup.sh
```

### Worker Node Configuration

Assign the second VM as the worker node. Copy and run the `worker_node_setup.sh` script to configure the worker node and join it to the master node:

```bash
scp worker_node_setup.sh root@<VM_IP>:/root
```

```bash
./worker_node_setup.sh
```

### Cluster Verification

Once both nodes are configured, verify that the cluster is running by checking the status of the nodes from the master node:

```bash
kubectl get nodes
```

Both nodes should appear with the `Ready` status.

### MPI and Flannel Installation

To enable communication between the nodes and support for the OSU benchmark, install `MPI` and `Flannel` on the master node using the `install_mpi_flannel.sh` script:

```bash
scp install_mpi_flannel.sh root@<VM_IP>:/root
```

Execute the script:

```bash
./install_mpi_flannel.sh
```

> **Note:** The installation follows guidelines from official documentation sources.

Check the status of the cluster’s pods:

```bash
kubectl get pods --all-namespaces -o wide
```

Once all pods are operational, reboot the master node to finalize network configuration.

### Deploying and Running the OSU Benchmark

Copy the `OSU_benchmarks` folder to the master node:

```bash
scp -r OSU_benchmarks root@<VM_IP>:/root/home
```

This directory contains the necessary manifests and scripts to run the OSU benchmark in the two-node `Kubernetes` cluster. The available benchmarks include:

- `latency-one-node`: Measures point-to-point latency between workers on the same node.
- `latency-two-nodes`: Measures point-to-point latency between workers on different nodes.
- `scatter-one-node`: Assesses scatter collective latency with workers on the same node.
- `scatter-two-nodes`: Assesses scatter collective latency with workers on different nodes.

To run a benchmark, navigate to the `OSU_benchmarks` folder and execute the corresponding script. For example, to run the `latency-one-node` benchmark:

```bash
cd /root/home/OSU_benchmarks
chmod +x latency_one_node.sh
./latency_one_node.sh
```

### Result Analysis

Results are stored in the `Results.txt` file within the `Results` directory. For visualizing and analyzing the results, use the provided `plot_results.ipynb` Jupyter notebook.
