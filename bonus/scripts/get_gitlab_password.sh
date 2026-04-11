#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Retrieving GitLab root password..."
kubectl get secret -n gitlab gitlab-root-password -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "Username: root"
echo "URL: http://gitlab.khbouy.local"
