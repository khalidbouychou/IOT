#!/bin/bash
set -e

PORT=8080
CLUSTER_NAME="cluster-khbouych"

# 1. Cleanup
echo "🧹 Cleaning up..."
k3d cluster delete $CLUSTER_NAME || true
sudo fuser -k $PORT/tcp || true

# 2. Create Cluster
echo "🚀 Creating K3d Cluster..."
k3d cluster create $CLUSTER_NAME -p "$PORT:80@loadbalancer" --wait

# 3. Setup Namespaces & Argo CD
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. Patch for Insecure/HTTP (Fixes 404/SSL)
echo "🔧 Patching ArgoCD..."
kubectl patch deployment argocd-server -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","command":["argocd-server","--insecure","--staticassets","/shared/app","--repo-server","argocd-repo-server:8081"]}]}}}}'

# 5. Wait and Background Port-Forward
echo "⏳ Waiting for Argo CD..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "📡 Starting Port-Forward in background (Logging to argocd.log)..."
# Start in background, redirect output to a file so you can watch it
nohup sudo kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 $PORT:80 > argocd.log 2>&1 &

# 6. Credentials
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "============================================================"
echo "🎯 SETUP COMPLETE"
echo "ArgoCD URL: http://localhost:$PORT"
echo "Username: admin | Pass: $PASS"
echo "------------------------------------------------------------"
echo "WATCH LOGS (See connections here): tail -f argocd.log"
echo "ON IMAC: ssh -L $PORT:localhost:$PORT leometti@10.13.100.241"
echo "============================================================"