#!/bin/bash

export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)

echo "Setting up port forwarding..."
echo "Argo CD UI will be available at: https://localhost:8080"
echo "Application will be available at: http://localhost:8888"
echo ""
echo "Press Ctrl+C to stop port forwarding"
echo ""

# Open Argo CD port forwarding in background
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
ARGOCD_PID=$!

# Keep port forward running
wait $ARGOCD_PID
