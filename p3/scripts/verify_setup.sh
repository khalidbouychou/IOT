#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy)

echo "=== Verifying K3d Cluster ==="
kubectl cluster-info
echo ""

echo "=== Checking Argo CD Namespace ==="
kubectl get namespace argocd
echo ""

echo "=== Checking Argo CD Pods ==="
kubectl get pods -n argocd
echo ""

echo "=== Checking Dev Namespace ==="
kubectl get namespace dev
echo ""

echo "=== Checking Application Deployment ==="
kubectl get deployment -n dev
echo ""

echo "=== Checking Application Pods ==="
kubectl get pods -n dev
echo ""

echo "=== Checking Application Service ==="
kubectl get svc -n dev
echo ""

echo "=== Checking Argo CD Application Status ==="
kubectl get application -n argocd
echo ""

echo "=== Testing Application ==="
echo "Attempting to access application at http://localhost:8888/"
curl -s http://localhost:8888/ || echo "Application not yet accessible"
echo ""

echo "=== Verification Complete ==="
