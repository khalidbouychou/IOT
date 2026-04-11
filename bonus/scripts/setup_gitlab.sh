#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Creating gitlab namespace..."
kubectl create namespace gitlab || true

echo "Installing GitLab via Helm..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /vagrant/confs/gitlab-values.yaml \
  --timeout 10m \
  --wait

echo "Waiting for GitLab to be ready..."
sleep 60

echo "GitLab installed successfully"
echo "You can access GitLab at: http://localhost"
