
# Cloud-Based File Storage System with Nextcloud on Kubernetes

This repository contains the configuration files and instructions for deploying a cloud-based file storage system using **Nextcloud** on **Kubernetes**, integrated with **PostgreSQL** as the database backend, **Redis** for caching, and **MetalLB** for load balancing. Below, you'll find a detailed guide on how to set up and run this system on your own Kubernetes cluster.

## Table of Contents

- [Introduction](#introduction)
- [Setup Requirements](#setup-requirements)
- [Configuration Files](#configuration-files)
  - [values.yaml](#valuesyaml)
  - [secrets.yaml](#secretsyaml)
  - [metallb.yaml](#metallbyaml)
  - [ingress.yaml](#ingressyaml)
- [Step-by-Step Guide](#step-by-step-guide)
  - [1. Setting Up the Namespace](#1-setting-up-the-namespace)
  - [2. Installing MetalLB](#2-installing-metallb)
  - [3. Deploying Nextcloud](#3-deploying-nextcloud)
  - [4. Configuring Ingress](#4-configuring-ingress)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

## Introduction

This project demonstrates how to deploy **Nextcloud**, an open-source file storage system, on Kubernetes. We use **PostgreSQL** for persistent data storage, **Redis** for caching and session handling, and **MetalLB** for IP management and load balancing in environments that lack cloud-based load balancers.

## Setup Requirements

- A running Kubernetes cluster (single-node K3s is recommended for local setups)
- Helm installed for managing Kubernetes packages
- MetalLB installed for load balancing

## Configuration Files

### `values.yaml`

This file contains configuration parameters for **Nextcloud**, **PostgreSQL**, and **Redis**. It includes liveness and readiness probes, persistent volume settings, and connections to external secrets.

\`\`\`yaml
nextcloud:
  host: nextcloud.local
  username: admin
  password: not_the_real_password
  dbType: pgsql
  persistence:
    enabled: true
    existingClaim: nextcloud-pvc
  livenessProbe:
    httpGet:
      path: /status.php
      port: 80
    initialDelaySeconds: 30
    timeoutSeconds: 5
    failureThreshold: 6
  readinessProbe:
    httpGet:
      path: /status.php
      port: 80
    initialDelaySeconds: 30
    timeoutSeconds: 5
    failureThreshold: 6

postgresql:
  enabled: true
  postgresqlUsername: nextcloud
  postgresqlPassword: not_the_real_password
  postgresqlDatabase: nextcloud
  livenessProbe:
    tcpSocket:
      port: 5432
    initialDelaySeconds: 30
    timeoutSeconds: 5
    failureThreshold: 6
  readinessProbe:
    tcpSocket:
      port: 5432
\`\`\`

### `secrets.yaml`

This file stores sensitive credentials like database passwords and the Nextcloud admin password. The values are Base64 encoded for security.

\`\`\`yaml
apiVersion: v1
kind: Secret
metadata:
  name: nextcloud-secrets
  namespace: nextcloud
type: Opaque
data:
  nextcloud-password: <base64-encoded-password>
  postgresql-password: <base64-encoded-password>
\`\`\`

### `metallb.yaml`

This file configures **MetalLB** for IP management and Layer 2 advertisement. MetalLB assigns an external IP to the Nextcloud service, making it accessible from outside the cluster.

\`\`\`yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: nextcloud-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.64.240-192.168.64.250

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: nextcloud-l2-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - nextcloud-pool
\`\`\`

### `ingress.yaml`

This file configures the **Ingress** resource to expose the Nextcloud service via a domain name (`nextcloud.local`). You can update the host field if you want to use a different domain.

\`\`\`yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nextcloud-ingress
  namespace: nextcloud
spec:
  rules:
    - host: nextcloud.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nextcloud
                port:
                  number: 8080
\`\`\`

## Step-by-Step Guide

### 1. Setting Up the Namespace

Create a dedicated namespace for **Nextcloud** to keep resources organized:

\`\`\`bash
kubectl create namespace nextcloud
\`\`\`

### 2. Installing MetalLB

1. First, install the required **MetalLB** CRDs:

   \`\`\`bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/crd/bases/metallb.io_ipaddresspools.yaml
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/crd/bases/metallb.io_l2advertisements.yaml
   \`\`\`

2. Create the `metallb-system` namespace and apply the MetalLB configuration:

   \`\`\`bash
   kubectl create namespace metallb-system
   kubectl apply -f metallb.yaml
   \`\`\`

### 3. Deploying Nextcloud

1. Apply the **secrets.yaml** file to create the necessary credentials:

   \`\`\`bash
   kubectl apply -f secrets.yaml --namespace nextcloud
   \`\`\`

2. Deploy Nextcloud with PostgreSQL and Redis using Helm:

   \`\`\`bash
   helm install nextcloud nextcloud/nextcloud --namespace nextcloud -f values.yaml
   \`\`\`

### 4. Configuring Ingress

Apply the **ingress.yaml** file to expose Nextcloud through a domain name:

\`\`\`bash
kubectl apply -f ingress.yaml --namespace nextcloud
\`\`\`

## Monitoring and Troubleshooting

To monitor the state of the pods and services, use the following commands:

- Check the status of the pods:

  \`\`\`bash
  kubectl get pods --namespace nextcloud
  \`\`\`

- View logs for any issues:

  \`\`\`bash
  kubectl logs <pod-name> --namespace nextcloud
  \`\`\`

- Restart the Nextcloud deployment if needed:

  \`\`\`bash
  kubectl rollout restart deployment nextcloud --namespace nextcloud
  \`\`\`

If there are network issues, ensure **MetalLB** is functioning properly by checking the services for an assigned external IP:

\`\`\`bash
kubectl get svc --namespace nextcloud
\`\`\`
