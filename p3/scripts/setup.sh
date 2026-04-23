# #!/bin/bash

# # 1. Install K3d
# # curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.4.6 bash

# curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_DIR=/goinfre/$(whoami)/bin USE_SUDO=false bash

# # Add k3d to PATH for the current session
# export PATH=$PATH:/goinfre/$(whoami)/bin
# # Also add it to your .zshrc so it stays forever
# echo 'export PATH=$PATH:/goinfre/'$(whoami)'/bin' >> ~/.zshrc

# # 2. Create Cluster
# # Port 8080: Argo CD UI
# # Port 8888: khbouychapp Playground App
# #8080:80@loadbalancer means forwarding port 8080 on the host to port 80 on the load balancer in the cluster, which is where the Argo CD server will be exposed.
# k3d cluster create khbouych-cluster \
#     -p "8080:80@loadbalancer" \  
#     -p "8888:8888@loadbalancer" \
#     --wait

# # 3. Namespaces
# kubectl create namespace argocd
# kubectl create namespace dev

# # 4. Install Argo CD
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# # 5. Wait for Argo CD to be ready (especially the server)
# echo "------------->  Waiting for Argo CD to start..."
# kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# # 6. Expose Argo CD UI
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# # 7. Get Password
# PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# echo "Argo CD UI: http://localhost:9443"
# echo "User: admin | Pass: $PASS"
# kubectl port-forward svc/argocd-server -n argocd 9443:443 --address 0.0.0.0



#!/bin/bash

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