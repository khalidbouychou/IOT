# Complete Setup Guide

## Prerequisites

### System Requirements
- **OS**: Linux or macOS
- **RAM**: 16GB minimum (8GB for Part 1-2, additional 8GB for bonus)
- **Disk Space**: 100GB
- **CPU**: 4+ cores recommended

### Software Requirements
- Vagrant 2.3.0+
- VirtualBox 7.0+
- Docker (for Part 3 & Bonus)
- kubectl (installed automatically by scripts)
- Git

### Installation

**Ubuntu/Debian**:
```bash
sudo apt-get install -y vagrant virtualbox git curl wget
```

**macOS**:
```bash
brew install vagrant virtualbox git
```

---

## Part 1: K3s and Vagrant (2 Nodes)

### Step 1: Navigate to Part 1
```bash
cd /goinfre/khbouych/IOT/p1
```

### Step 2: Start VMs
```bash
vagrant up
```

This will:
- Create khbouyS (server) at 192.168.56.110
- Create khbouyW (worker) at 192.168.56.111
- Install K3s in server mode on khbouyS
- Install K3s in agent mode on khbouyW

### Step 3: Verify Setup
```bash
# SSH into server node
vagrant ssh khbouyS

# Inside VM:
kubectl get nodes
kubectl get pods -A

# Check status
systemctl status k3s
```

### Expected Output
```
NAME     STATUS   ROLES                  AGE   VERSION
khbouyS  Ready    control-plane,master   2m    v1.xx.x
khbouyW  Ready    <none>                 1m    v1.xx.x
```

### Step 4: Test Connectivity
```bash
# From host machine
vagrant ssh khbouyS
kubectl get nodes

# Worker should be in Ready state
# If not, wait a few more seconds and retry
```

---

## Part 2: K3s with 3 Applications

### Step 1: Navigate to Part 2
```bash
cd /goinfre/khbouych/IOT/p2
```

### Step 2: Start VM
```bash
vagrant up
```

This will:
- Create khbouyS at 192.168.56.110
- Install K3s in server mode
- Deploy 3 applications with Ingress

### Step 3: Verify Deployment
```bash
# SSH into VM
vagrant ssh khbouyS

# Check pods
kubectl get pods
kubectl get svc
kubectl get ingress

# Check app1 deployment
kubectl get deployment app1
```

### Step 4: Access Applications

From your host machine, add to `/etc/hosts`:
```
192.168.56.110  app1.com
192.168.56.110  app2.com
192.168.56.110  khbouyS
```

Then access:
```bash
# App 1
curl http://app1.com

# App 2 (3 replicas)
curl http://app2.com

# App 3 (default)
curl http://192.168.56.110
curl http://khbouyS
```

### Step 5: View Application Replicas
```bash
vagrant ssh khbouyS

# Check app2 replicas
kubectl get pods -l app=app2
kubectl describe deployment app2
```

---

## Part 3: K3d and Argo CD

### Step 1: Install Dependencies (Host Machine)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
```

### Step 2: Create K3d Cluster
```bash
# Install K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create cluster
k3d cluster create khbouy \
  --agents 2 \
  -p "8888:8888@loadbalancer" \
  --wait

# Verify
k3d cluster list
```

### Step 3: Install Argo CD
```bash
# Get kubeconfig
export KUBECONFIG=$(k3d kubeconfig get khbouy)

# Create namespace
kubectl create namespace argocd

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Create dev namespace
kubectl create namespace dev
```

### Step 4: Prepare GitHub Repository

1. Create GitHub repository: `https://github.com/YOUR_USERNAME/khbouy-iot`

2. Clone it:
   ```bash
   git clone https://github.com/YOUR_USERNAME/khbouy-iot.git
   cd khbouy-iot
   ```

3. Create directory structure:
   ```bash
   mkdir -p k3d
   ```

4. Copy deployment manifest:
   ```bash
   cp /goinfre/khbouych/IOT/p3/confs/deployment.yaml k3d/
   ```

5. Push to GitHub:
   ```bash
   git add k3d/deployment.yaml
   git commit -m "Add deployment manifest"
   git push origin master
   ```

### Step 5: Configure Argo CD Application

Edit `/goinfre/khbouych/IOT/p3/confs/argocd-app.yaml`:
```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/khbouy-iot
  targetRevision: master
  path: k3d
```

### Step 6: Deploy with Argo CD
```bash
export KUBECONFIG=$(k3d kubeconfig get khbouy)
kubectl apply -f /goinfre/khbouych/IOT/p3/confs/argocd-app.yaml
```

### Step 7: Verify Deployment
```bash
# Check Argo CD application
kubectl get application -n argocd
kubectl describe application khbouy-app -n argocd

# Check deployed pod
kubectl get pods -n dev
kubectl get svc -n dev

# Access application
curl http://localhost:8888/
```

### Step 8: Access Argo CD UI
```bash
# Get password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
echo ""

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Access: https://localhost:8080
# Username: admin
# Password: (from above)
```

### Step 9: Test GitOps Workflow

1. Update GitHub repository:
   ```bash
   cd khbouy-iot
   sed -i 's/wil42\/playground\:v1/wil42\/playground\:v2/g' k3d/deployment.yaml
   git add k3d/deployment.yaml
   git commit -m "Update to v2"
   git push origin master
   ```

2. Check Argo CD for sync (max 3 minutes):
   ```bash
   kubectl get application -n argocd
   ```

3. Verify new version:
   ```bash
   curl http://localhost:8888/
   # Should show: {"status":"ok", "message": "v2"}
   ```

---

## Bonus: GitLab + K3d + Argo CD

### Step 1: Navigate to Bonus
```bash
cd /goinfre/khbouych/IOT/bonus
```

### Step 2: Start GitLab VM
```bash
vagrant up
```

This will automatically:
- Install Docker, Helm, kubectl
- Create K3d cluster
- Install GitLab via Helm
- Install Argo CD

### Step 3: Get GitLab Password
```bash
bash scripts/get_gitlab_password.sh
```

### Step 4: Access GitLab
- URL: `http://localhost`
- Username: `root`
- Password: (from step 3)

### Step 5: Create GitLab Repository

1. Login to GitLab
2. Create new project: `khbouy-iot`
3. Make it private or public

### Step 6: Push Manifests to GitLab

```bash
# Clone GitLab repo
git clone http://root:PASSWORD@localhost/root/khbouy-iot.git
cd khbouy-iot

# Create structure
mkdir -p k3d

# Copy manifests
cp /goinfre/khbouych/IOT/p3/confs/deployment.yaml k3d/

# Push
git add .
git commit -m "Add Kubernetes manifests"
git push origin master
```

### Step 7: Generate GitLab Token

1. In GitLab: **Settings → Access Tokens**
2. Create token: `argocd-token`
3. Scopes: `api`, `read_api`
4. Copy token

### Step 8: Configure Argo CD

Edit `/goinfre/khbouych/IOT/bonus/confs/argocd-gitlab-integration.yaml`:
```yaml
password: YOUR_GITLAB_TOKEN_HERE
```

Apply configuration:
```bash
export KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)
kubectl apply -f /goinfre/khbouych/IOT/bonus/confs/argocd-gitlab-integration.yaml
```

### Step 9: Verify Integration

```bash
bash /goinfre/khbouych/IOT/bonus/scripts/verify_bonus_setup.sh
```

### Step 10: Test GitOps with GitLab

1. Update manifest in GitLab:
   ```bash
   cd khbouy-iot
   sed -i 's/:v1/:v2/g' k3d/deployment.yaml
   git add k3d/deployment.yaml
   git commit -m "Update to v2"
   git push origin master
   ```

2. Argo CD syncs automatically

3. Verify:
   ```bash
   curl http://localhost:8888/
   ```

---

## Cleanup

### Part 1 & 2 (Vagrant)
```bash
cd p1  # or p2
vagrant destroy
```

### Part 3 (K3d)
```bash
k3d cluster delete khbouy
```

### Bonus (K3d + Vagrant)
```bash
cd bonus
vagrant destroy
# Then:
k3d cluster delete khbouy-gitlab
```

---

## Debugging Commands

### Vagrant
```bash
vagrant status
vagrant ssh khbouyS
vagrant halt
vagrant resume
vagrant destroy -f
```

### Kubernetes
```bash
kubectl describe pod pod-name -n namespace
kubectl logs pod-name -n namespace
kubectl get events -n namespace
kubectl top pods -n namespace
kubectl exec -it pod-name -n namespace -- /bin/bash
```

### K3d
```bash
k3d cluster list
k3d cluster start khbouy
k3d cluster stop khbouy
k3d cluster delete khbouy
k3d kubeconfig get khbouy
k3d cluster logs khbouy
```

### Docker
```bash
docker ps
docker logs container-id
docker exec -it container-id bash
```

---

## Common Issues and Solutions

### Issue: VMs won't start
**Solution**: 
- Check VirtualBox is installed: `vboxmanage --version`
- Ensure enough disk space: 50GB minimum
- Check RAM availability: `free -h`

### Issue: K3s taking too long to start
**Solution**:
- Wait 30-60 seconds before checking status
- Check logs: `journalctl -u k3s -f`

### Issue: Argo CD not syncing
**Solution**:
- Check internet connectivity
- Verify GitHub token has correct permissions
- Force sync: `kubectl patch application khbouy-app -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"now"}}}' --type merge`

### Issue: Port forwarding not working
**Solution**:
- Kill existing processes: `lsof -i :8080`
- Use different port: `kubectl port-forward svc/argocd-server -n argocd 9080:443`

---

## Performance Tips

1. **Increase VM resources** if operations are slow
2. **Use SSD** for better performance
3. **Close unnecessary applications** before running VMs
4. **Monitor resource usage**: `kubectl top nodes`

---

## Next Steps

After completing all parts:
1. Explore Kubernetes more: `kubectl api-resources`
2. Learn Helm: `helm repo search`
3. Dive into Argo CD advanced features
4. Set up monitoring with Prometheus/Grafana
5. Implement network policies for security
