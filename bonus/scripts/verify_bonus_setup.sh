#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "=== Verifying Bonus Setup ==="
echo ""

echo "=== K3d Cluster Status ==="
k3d cluster list
echo ""

echo "=== Kubernetes Cluster Info ==="
kubectl cluster-info
echo ""

echo "=== Checking Namespaces ==="
kubectl get namespace
echo ""

echo "=== Checking GitLab Installation ==="
kubectl get pods -n gitlab
kubectl get svc -n gitlab
echo ""

echo "=== Checking Argo CD Installation ==="
kubectl get pods -n argocd
kubectl get svc -n argocd
echo ""

echo "=== Checking Dev Namespace ==="
kubectl get pods -n dev
kubectl get svc -n dev
echo ""

echo "=== Checking GitLab Runner ==="
kubectl get pods -n gitlab-runner 2>/dev/null || echo "GitLab Runner not yet installed"
echo ""

echo "=== Checking Ingress Configuration ==="
kubectl get ingress -A
echo ""

echo "=== Checking PersistentVolumes ==="
kubectl get pv
echo ""

echo "=== Checking PersistentVolumeClaims ==="
kubectl get pvc -A
echo ""

echo "=== Verification Complete ==="
