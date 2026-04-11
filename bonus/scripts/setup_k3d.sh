#!/bin/bash
set -e

echo "Installing K3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "Creating K3d cluster with increased resources..."
k3d cluster create khbouy-gitlab \
  --agents 3 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  -p "8080:8080@loadbalancer" \
  -p "8888:8888@loadbalancer" \
  --wait

echo "K3d cluster created successfully"
