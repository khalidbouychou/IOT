#!/bin/bash
set -e

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Creating gitlab-runner namespace..."
kubectl create namespace gitlab-runner || true

echo "Installing GitLab Runner via Helm..."
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set gitlabUrl="http://gitlab.khbouy.local/" \
  --set gitlabToken="<YOUR_RUNNER_TOKEN>" \
  --set runners.image="ubuntu:20.04" \
  --set runners.privileged="true" \
  --wait

echo "GitLab Runner installed successfully"
echo "Note: Replace <YOUR_RUNNER_TOKEN> with actual token from GitLab"
