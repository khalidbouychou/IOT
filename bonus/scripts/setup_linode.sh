#!/bin/bash
set -e

echo "=== Linode Kubernetes Engine (LKE) Setup ==="
echo ""
echo "Linode LKE pricing:"
echo "  - $10/month per node (2GB RAM, 1vCPU minimum)"
echo "  - Free $100 credit for new accounts"
echo "  - Simple, transparent pricing"
echo ""

# Check if linode-cli is installed
if ! command -v linode-cli &> /dev/null; then
    echo "Installing Linode CLI..."
    pip3 install linode-cli
fi

echo ""
echo "Step 1: Configure Linode CLI"
linode-cli configure

echo ""
echo "Step 2: Create LKE cluster"
read -p "Enter cluster label (e.g., khbouy-lke): " CLUSTER_LABEL
read -p "Enter region (e.g., us-east): " LINODE_REGION
read -p "Enter number of nodes (e.g., 2): " NODE_COUNT

# Create cluster
CLUSTER_ID=$(linode-cli lke cluster-create \
  --label "$CLUSTER_LABEL" \
  --region "$LINODE_REGION" \
  --json | jq -r '.[0].id')

echo "Cluster created: $CLUSTER_ID"

echo ""
echo "Step 3: Wait for cluster to be ready"
sleep 30

echo "Step 4: Download kubeconfig"
mkdir -p ~/.kube
linode-cli lke kubeconfig-view "$CLUSTER_ID" \
  > ~/.kube/linode-kubeconfig.yaml

chmod 600 ~/.kube/linode-kubeconfig.yaml
export KUBECONFIG=~/.kube/linode-kubeconfig.yaml

echo ""
echo "Step 5: Verify cluster access"
kubectl cluster-info

echo ""
echo "Step 6: Install Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo ""
echo "Step 7: Install GitLab"
helm repo add gitlab https://charts.gitlab.io
helm repo update

kubectl create namespace gitlab
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /path/to/gitlab-values-linode.yaml

echo ""
echo "Step 8: Install Argo CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "Deployment complete!"
echo "Cluster ID: $CLUSTER_ID"
echo ""
echo "Delete cluster when done:"
echo "linode-cli lke cluster-delete $CLUSTER_ID"
