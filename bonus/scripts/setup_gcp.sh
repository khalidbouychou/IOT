#!/bin/bash
set -e

echo "=== Google Cloud Platform Setup ==="
echo ""
echo "GCP provides $300 free credit for 3 months:"
echo "  - Google Kubernetes Engine (GKE)"
echo "  - Cloud SQL"
echo "  - Cloud Storage"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Installing Google Cloud CLI..."
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
fi

echo ""
echo "Step 1: Initialize gcloud"
gcloud init

echo ""
echo "Step 2: Set default project"
gcloud config list
read -p "Enter your GCP Project ID: " PROJECT_ID
gcloud config set project "$PROJECT_ID"

echo ""
echo "Step 3: Enable required APIs"
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable containerregistry.googleapis.com

echo ""
echo "Step 4: Create GKE cluster"
read -p "Enter cluster name (e.g., khbouy-gke): " CLUSTER_NAME
read -p "Enter region (e.g., us-central1): " GCP_REGION
read -p "Enter number of nodes (e.g., 2): " NODE_COUNT

gcloud container clusters create "$CLUSTER_NAME" \
  --region "$GCP_REGION" \
  --num-nodes "$NODE_COUNT" \
  --machine-type n1-standard-1 \
  --enable-stackdriver-kubernetes

echo ""
echo "Step 5: Get credentials"
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --region "$GCP_REGION"

echo ""
echo "Step 6: Install Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo ""
echo "Step 7: Install GitLab on GCP"
helm repo add gitlab https://charts.gitlab.io
helm repo update

kubectl create namespace gitlab
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /path/to/gitlab-values-gcp.yaml

echo ""
echo "Step 8: Install Argo CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "Deployment complete!"
echo ""
echo "Clean up when done:"
echo "gcloud container clusters delete $CLUSTER_NAME --region $GCP_REGION"
