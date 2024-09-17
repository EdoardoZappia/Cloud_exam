# MPI Service Deployment on Kubernetes

This directory contains the solution for the second task of the **Cloud Advanced** assignment, which involves deploying and executing the [OSU benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) on a two-node `Kubernetes` cluster, with each container distributed across two separate nodes.

## Directory Overview

The structure of this folder is organized as follows:

```bash
.
├── README.md                 # This guide
├── Dockerfiles_MPI_OSU        # Dockerfiles for building the OSU benchmark containers
│   ├── Dockerfile
│   ├── openmpi-builder.Dockerfile
│   ├── openmpi.Dockerfile
│   └── osu-code-provider.Dockerfile
├── OSU_benchmarks             # Scripts and manifests for the OSU benchmark
│   ├── Results                # Directory for storing benchmark results
│   │   └── Results.txt
│   ├── latency-one-node.yaml
│   ├── latency-two-nodes.yaml
│   ├── latency_one_node.sh
│   ├── latency_two_nodes.sh
│   ├── plot_results.ipynb     # Jupyter notebook for plotting benchmark results
│   ├── scatter-one-node.yaml
│   ├── scatter-two-nodes.yaml
│   ├── scatter_one_node.sh
│   └── scatter_two_nodes.sh
├── common_initial_setup.sh    # Initial setup script for master and worker nodes
├── install_mpi_flannel.sh     # MPI and Flannel installation script for the master node
├── master_node_setup.sh       # Setup script for configuring the master node
└── worker_node_setup.sh       # Setup script for configuring the worker node
```

## Setup Instructions

To deploy and execute the OSU benchmark, two virtual machines (VMs) must be created, each running `Kubernetes` with the necessary components, forming a two-node `Kubernetes` cluster.

### Virtual Machine Setup

Start by creating two new VMs using the Fedora 39 image. This example uses `UTM` for virtualization on a `macOS` host, but other tools such as `VirtualBox` can be used based on your environment. Ensure that each VM is provisioned with at least 2 CPUs and 2 GB of RAM.

During VM creation, enable `SSH` root login to facilitate easier access from the host machine. To connect to the VM via `SSH`, use the following command:

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
