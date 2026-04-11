#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Retrieving Argo CD admin password..."
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "Username: admin"
