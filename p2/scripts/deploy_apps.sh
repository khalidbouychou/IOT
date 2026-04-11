#!/bin/bash
set -e

sleep 10

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Apply manifests
/usr/local/bin/kubectl apply -f /vagrant/confs/app1-deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/app2-deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/app3-deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/ingress.yaml

echo "Applications deployed successfully"
