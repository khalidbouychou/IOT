#!/bin/bash

# --- 1. SET ENVIRONMENT ---
export PATH="/goinfre/$(whoami)/bin:$PATH"
GOINFRE="/goinfre/$(whoami)"
export PATH="$PATH:$GOINFRE/bin"

k3d cluster create bonus-clr -p "8080:80@loadbalancer" -p "8888:8888@loadbalancer" --wait
kubectl create namespace gitlab

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace argocd
# --- 2. GET GITLAB PASSWORD ---
echo "--- 🔑 Retrieving GitLab Root Password ---"
GITLAB_PASS=$(vagrant ssh gitlab-server -c "sudo cat /etc/gitlab/initial_root_password" | grep "Password:" | awk '{print $2}' | tr -d '\r')
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Password found: $GITLAB_PASS"
echo "---------------------Gitlab Cpanel---------------------------------------"
echo "✅ BONUS PART IS READY"
echo "GitLab URL: http://192.168.56.120"
echo "GitLab User: root"
echo "GitLab Pass: $GITLAB_PASS"
echo "------------------------AgroCD------------------------------------"
echo "ArgoCD URL: http://192.168.56.120"
echo "ArgoCD User: admin"
echo "ArgoCD Pass: $PASS"
echo "------------------------------------------------------------"
echo "after creating repo run these commands : 
-  vagrant suspend gitlab-server \n
- k3d kubeconfig merge bonus-clr  --kubeconfig-switch-context \n
- kubectl apply -f confs/application-bonus.yaml \n
- vagrant resume gitlab-server \n
- kubectl port-forward -n argocd svc/argocd-server 8080:443
"