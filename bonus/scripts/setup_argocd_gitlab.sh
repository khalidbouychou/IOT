#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Creating argocd namespace..."
kubectl create namespace argocd || true

echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "Creating dev namespace..."
kubectl create namespace dev || true

echo "Argo CD installed successfully"
