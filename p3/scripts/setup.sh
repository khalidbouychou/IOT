# #!/bin/bash

# 1. Environment Setup
LOCAL_BIN="/goinfre/$(whoami)/bin"
mkdir -p $LOCAL_BIN
export PATH=$PATH:$LOCAL_BIN

# 2. Install K3d locally
if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_DIR=$LOCAL_BIN USE_SUDO=false bash
fi

# 3. Create Cluster
# Port 8080: For Argo CD UI
# Port 8888: For the App
echo "Creating K3d cluster..."
k3d cluster create khbouych-cluster \
    -p "8080:80@loadbalancer" \
    -p "8888:8888@loadbalancer" \
    --wait

# 4. Create Namespaces
kubectl create namespace argocd
kubectl create namespace dev

# 5. Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 6. Wait for Argo CD to start
echo "Waiting for Argo CD pods..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# 7. Get Argo CD Password
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "---------------------------------------------------"
echo "Argo CD UI: http://localhost:8080"
echo "Login: admin"
echo "Password: $PASS"
# Port forward for Argo CD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443
echo "---------------------------------------------------"