#!/bin/bash

# This script is used to estimate the latency of the scatter collective operation by
# running the OSU latency benchmark on a single node.

# Create the osu-benchmark namespace if it does not exist
if [ -z "$(kubectl get ns osu-benchmark)" ]; then
    kubectl create ns osu-benchmark
fi

# Create the Results directory if it does not exist
if [ ! -d "Results" ]; then
    mkdir Results
fi

# Create the output file in the Results directory if it does not exist
if [ ! -f "Results/Results.txt" ]; then
    touch Results/Results.txt
fi

# Apply the scatter-one-node.yaml file to the cluster
echo "------------------- Running OSU Benchmark (scatter-one-node) -------------------" >> Results/Results.txt
kubectl apply -f scatter-one-node.yaml -n osu-benchmark

# Wait for the pod to be in the running state and to complete
export pod_status=""
while [ "$pod_status" != "Completed" ]; do
    echo "Waiting for the pod to be in the running state and to complete..."
    sleep 10
    pod_status=$(kubectl get pod -n osu-benchmark | grep launcher | awk '{print $3}')
done

# Get the name of the pod
export pod_name=$(kubectl get pods -n osu-benchmark | grep launcher | awk '{print $1}')

# Write the latency results to the output .txt file
kubectl logs $pod_name -n osu-benchmark >> Results/Results.txt

# Print the results to the console as well
kubectl logs $pod_name -n osu-benchmark
echo "Results have been written to Results/Results.txt"

# Free up the resources
kubectl delete -f scatter-one-node.yaml -n osu-benchmark
