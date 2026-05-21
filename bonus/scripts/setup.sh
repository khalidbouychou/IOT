#!/bin/bash
# set -e 
# Configuration
DROPLET_IP=$(curl -s ifconfig.me)
GL_PORT=80
ACD_PORT=8080

# 1. Cleanup
docker stop $(docker ps -a -q) || true
docker rm $(docker ps -a -q) || true
docker system prune -a --volumes -f || true
k3d cluster delete --all || true
sudo fuser -k $PORT/tcp || true


# 1. Setup Swap (Crucial for GitLab stability)
sudo fallocate -l 2G /swapfile || true
sudo chmod 600 /swapfile || true
sudo mkswap /swapfile || true
sudo swapon /swapfile || true

# 2. GitLab (Docker)
sudo docker run -d --name gitlab-local --hostname $DROPLET_IP -p $GL_PORT:80 --restart always \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://$DROPLET_IP'; puma['worker_processes'] = 0; prometheus_monitoring['enable'] = false;" \
  -v ~/iot-gitlab/config:/etc/gitlab -v ~/iot-gitlab/logs:/var/log/gitlab -v ~/iot-gitlab/data:/var/opt/gitlab \
  --shm-size 256m gitlab/gitlab-ce:latest > /dev/null

# 3. K3d Cluster
k3d cluster delete bonus-clr || true
k3d cluster create bonus-clr --api-port 6443 -p "$ACD_PORT:80@loadbalancer" --wait
export KUBECONFIG=$(k3d kubeconfig write bonus-clr)

# 4. Argo CD
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch deployment argocd-server -n argocd \ 
-p \
'{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","command":["argocd-server","--insecure","--staticassets","/shared/app","--repo-server","argocd-repo-server:8081"]}]}}}}'

echo "⏳ Waiting for Argo CD secret..."
while ! kubectl -n argocd get secret argocd-initial-admin-secret >/dev/null 2>&1; do
    echo "."
    sleep 5
done

# 5. Credentials
PASS_ACD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
PASS_GITLAB=$(sudo docker exec gitlab-local grep 'Password:' /etc/gitlab/initial_root_password | awk '{print $2}')

kubectl apply -f confs/application-bonus.yaml
# kubectl rollout status deployment/argocd-server -n argocd --timeout=300s



echo "============================================================"
echo "🎯 SETUP COMPLETE"
echo "ArgoCD URL: http://209.38.231.135:$ACD_PORT"
echo "Username: admin | Pass: $PASS_ACD"
echo "------------------------------------------------------------"
echo "Gitlab URL: https://209.38.231.135"
echo "Username: root | Pass: $PASS_GITLAB"
echo "------------------------------------------------------------"
echo "To finish Bonus: run : docker ps and wait gitlab until be healthy"
echo "To view UI: 'sudo kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8081:80'"
echo "============================================================"
