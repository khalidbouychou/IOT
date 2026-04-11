#!/bin/bash
set -e

# Install K3s in server mode
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -

# Wait for K3s to be ready
sleep 5

# Copy kubeconfig for root user
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config

# Install kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

# Get the token for worker nodes
echo "K3s Server installed successfully"
