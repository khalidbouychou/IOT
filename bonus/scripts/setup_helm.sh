#!/bin/bash
set -e

echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Adding Helm repositories..."
helm repo add gitlab https://charts.gitlab.io
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo "Helm installed successfully"
