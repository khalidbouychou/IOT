#!/bin/bash
set -e

echo "=== Digital Ocean K8s Setup Script ==="
echo "This script prepares your DigitalOcean Kubernetes cluster"
echo ""

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "Installing doctl (DigitalOcean CLI)..."
    cd ~
    wget https://github.com/digitalocean/doctl/releases/download/v1.99.0/doctl-1.99.0-linux-amd64.tar.gz
    tar xf ~/doctl-1.99.0-linux-amd64.tar.gz
    sudo mv ~/doctl /usr/local/bin
    rm doctl-1.99.0-linux-amd64.tar.gz
fi

echo "Authenticating with DigitalOcean..."
read -p "Enter your DigitalOcean API token: " DO_TOKEN
doctl auth init --access-token "$DO_TOKEN"

echo "Listing available Kubernetes clusters..."
doctl kubernetes cluster list

read -p "Enter your cluster name: " CLUSTER_NAME

echo "Getting kubeconfig for cluster: $CLUSTER_NAME"
doctl kubernetes cluster kubeconfig save "$CLUSTER_NAME"

export KUBECONFIG=~/.kube/$CLUSTER_NAME-kubeconfig.yaml

echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io
helm repo update

echo "Creating gitlab namespace..."
kubectl create namespace gitlab

echo "Installing GitLab on DigitalOcean..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /path/to/gitlab-values-do.yaml \
  --wait

echo "Installing Argo CD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Creating dev namespace..."
kubectl create namespace dev

echo "Setup complete!"
echo "GitLab will be available at: http://gitlab.<your-do-domain>"
