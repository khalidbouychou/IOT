#!/bin/bash

# 1. Install K3d
# curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.4.6 bash

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_DIR=/goinfre/$(whoami)/bin USE_SUDO=false bash

# Add k3d to PATH for the current session
export PATH=$PATH:/goinfre/$(whoami)/bin
# Also add it to your .zshrc so it stays forever
echo 'export PATH=$PATH:/goinfre/'$(whoami)'/bin' >> ~/.zshrc

# 2. Create Cluster
# Port 8080: Argo CD UI
# Port 8888: Wil's Playground App
k3d cluster create mycluster \
    -p "8080:80@loadbalancer" \
    -p "8888:8888@loadbalancer" \
    --wait

# 3. Namespaces
kubectl create namespace argocd
kubectl create namespace dev

# 4. Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5. Wait for Argo CD to be ready (especially the server)
echo "Waiting for Argo CD to start..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# 6. Expose Argo CD UI
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 7. Get Password
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD UI: http://localhost:8080"
echo "User: admin | Pass: $PASS"