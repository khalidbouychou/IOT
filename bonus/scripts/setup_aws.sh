#!/bin/bash
set -e

echo "=== AWS EKS Deployment Setup ==="
echo ""
echo "AWS provides 12-month FREE tier including:"
echo "  - EC2 instances"
echo "  - ECS/EKS free tier"
echo "  - 30GB data transfer"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
fi

echo ""
echo "Step 1: Configure AWS credentials"
aws configure

echo ""
echo "Step 2: Create EKS cluster"
read -p "Enter cluster name (e.g., khbouy-eks): " CLUSTER_NAME
read -p "Enter AWS region (e.g., us-east-1): " AWS_REGION
read -p "Enter number of nodes (e.g., 2): " NODE_COUNT

eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --nodegroup-name standard-nodes \
  --node-type t3.medium \
  --nodes "$NODE_COUNT" \
  --nodes-min 1 \
  --nodes-max 4

echo ""
echo "Step 3: Update kubeconfig"
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$CLUSTER_NAME"

echo ""
echo "Step 4: Install Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo ""
echo "Step 5: Install GitLab"
helm repo add gitlab https://charts.gitlab.io
helm repo update

kubectl create namespace gitlab
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /path/to/gitlab-values-aws.yaml

echo ""
echo "Step 6: Install Argo CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "Deployment complete!"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $AWS_REGION"
echo ""
echo "Important: Delete resources when done to avoid charges!"
echo "eksctl delete cluster --region $AWS_REGION --name $CLUSTER_NAME"
