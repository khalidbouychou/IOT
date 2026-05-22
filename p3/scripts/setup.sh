#!/bin/bash

PORT=8080
CLUSTER_NAME="cluster-khbouych"

# 1. Cleanup
docker stop $(docker ps -a -q) || true
docker rm $(docker ps -a -q) || true
docker system prune -a --volumes -f || true
k3d cluster delete $CLUSTER_NAME || true
k3d cluster delete --all || true
sudo fuser -k $PORT/tcp || true

# 2. Create Cluster
k3d cluster create $CLUSTER_NAME -p "$PORT:80@loadbalancer" --wait

# 3. Setup Namespaces & Argo CD
kubectl create namespace argocd 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. WAIT for the secret to be created
echo "⏳ Waiting for Argo CD secret..."
while ! kubectl -n argocd get secret argocd-initial-admin-secret >/dev/null 2>&1; do
    sleep 5
done

# 5. Credentials
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# 6. Final Setup
kubectl apply -f confs/application.yaml || echo "⚠️ application.yaml not found"

echo "============================================================"
echo "🎯 SETUP COMPLETE"
echo "ArgoCD URL: http://209.38.231.135:$PORT"
echo "Username: admin | Pass: $PASS"
echo "------------------------------------------------------------"
echo "To finish Bonus: run 'kubectl apply -f confs/application-bonus.yaml'"
echo "To view UI: 'sudo kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8081:80'"
echo "============================================================"