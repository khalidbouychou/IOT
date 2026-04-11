# Part 3: K3d and Argo CD

## Overview
This part sets up a complete CI/CD pipeline using K3d (lightweight Kubernetes) and Argo CD for GitOps-based continuous deployment.

## Key Differences: K3s vs K3d

| Feature | K3s | K3d |
|---------|-----|-----|
| Deployment | Runs on VMs/servers | Runs in Docker containers |
| Use Case | Production-like environments | Local development & testing |
| Resources | Minimal but on host OS | Minimal, containerized |
| Setup Time | Longer | Faster |

## Architecture

```
┌─────────────────────────────────────┐
│        K3d Cluster                  │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │   Argo CD Namespace          │   │
│  │  ┌──────────────────────┐    │   │
│  │  │  Argo CD Server      │    │   │
│  │  │  Argo CD Repo Server │    │   │
│  │  │  Argo CD Controller  │    │   │
│  │  └──────────────────────┘    │   │
│  └──────────────────────────────┘   │
│                                     │
│  ┌──────────────────────────────┐   │
│  │   Dev Namespace              │   │
│  │  ┌──────────────────────┐    │   │
│  │  │  Playground App v1   │    │   │
│  │  │  (Auto-synced from   │    │   │
│  │  │   GitHub)            │    │   │
│  │  └──────────────────────┘    │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
         ↓
   Pulls from GitHub
   (deployment.yaml)
```

## Prerequisites

- **RAM**: At least 4GB free
- **Disk Space**: 2GB minimum
- **Internet**: Required for pulling images and cloning from GitHub

## Installation & Setup

### Step 1: Install Dependencies

Run the setup script to install Docker, K3d, and kubectl:

```bash
bash p3/scripts/setup_k3d.sh
```

This script will:
- Install Docker
- Install K3d
- Install kubectl
- Create a K3d cluster named `khbouy` with 2 agents
- Expose port 8888 for the application

### Step 2: Install Argo CD

```bash
bash p3/scripts/setup_argocd.sh
```

This script will:
- Create the `argocd` namespace
- Install Argo CD manifests
- Create the `dev` namespace

### Step 3: Prepare GitHub Repository

1. Create a public GitHub repository:
   ```
   Repository name: khbouy-iot (or similar)
   ```

2. Clone your repository locally and create the required structure:
   ```bash
   git clone https://github.com/YOUR_USERNAME/khbouy-iot.git
   cd khbouy-iot
   mkdir -p k3d
   ```

3. Copy the deployment manifest:
   ```bash
   cp p3/confs/deployment.yaml khbouy-iot/k3d/deployment.yaml
   ```

4. Commit and push:
   ```bash
   cd khbouy-iot
   git add k3d/deployment.yaml
   git commit -m "Add K3d deployment manifest"
   git push origin master
   ```

### Step 4: Update Argo CD Application Manifest

Edit `p3/confs/argocd-app.yaml` and update:

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/khbouy-iot
  targetRevision: master
  path: k3d
```

### Step 5: Deploy Application with Argo CD

```bash
export KUBECONFIG=$(k3d kubeconfig get khbouy)
kubectl apply -f p3/confs/argocd-app.yaml
```

## Verification

### Check All Resources

```bash
bash p3/scripts/verify_setup.sh
```

### Manual Verification

```bash
# Check K3d cluster
k3d cluster list

# Set kubeconfig
export KUBECONFIG=$(k3d kubeconfig get khbouy)

# Check namespaces
kubectl get namespace

# Check Argo CD status
kubectl get pods -n argocd

# Check application deployment
kubectl get pods -n dev
kubectl get svc -n dev

# Test application
curl http://localhost:8888/
```

## Accessing Services

### Argo CD UI

1. Get the admin password:
   ```bash
   bash p3/scripts/get_argocd_password.sh
   ```

2. Port forward to Argo CD server:
   ```bash
   bash p3/scripts/port_forward.sh
   ```

3. Access at: `https://localhost:8080`

4. Login with:
   - Username: `admin`
   - Password: (from step 1)

### Application

Access the deployed application directly:
```bash
curl http://localhost:8888/
```

Expected output for v1:
```json
{"status":"ok", "message": "v1"}
```

## Switching Application Versions

### Using GitHub (Automatic via Argo CD)

1. Update your GitHub repository:
   ```bash
   cd khbouy-iot
   sed -i 's/wil42\/playground\:v1/wil42\/playground\:v2/g' k3d/deployment.yaml
   git add k3d/deployment.yaml
   git commit -m "Update to v2"
   git push origin master
   ```

2. Check Argo CD for automatic sync (may take up to 3 minutes):
   ```bash
   kubectl get application -n argocd
   ```

3. Verify the new version is running:
   ```bash
   kubectl get deployment -n dev -o jsonpath='{.items[0].spec.template.spec.containers[0].image}'
   echo ""
   ```

4. Test the application:
   ```bash
   curl http://localhost:8888/
   ```

Expected output for v2:
```json
{"status":"ok", "message": "v2"}
```

### Manual Sync (if needed)

If Argo CD doesn't auto-sync immediately:
```bash
# Force sync
kubectl patch application khbouy-app -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"now"}}}' --type merge
```

## Troubleshooting

### K3d cluster won't start
```bash
# Check if Docker is running
docker ps

# Check K3d logs
k3d cluster logs khbouy

# Delete and recreate cluster
k3d cluster delete khbouy
bash p3/scripts/setup_k3d.sh
```

### Argo CD pods not running
```bash
# Check pod events
kubectl describe pod -n argocd

# Check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Application not accessible
```bash
# Check pod status
kubectl get pods -n dev

# Check pod logs
kubectl logs -n dev -l app=playground

# Check service
kubectl get svc -n dev

# Check ingress/port forward
kubectl port-forward svc/playground-service -n dev 8888:8888
```

### Argo CD Application shows "OutOfSync"
```bash
# Check application status
kubectl describe application khbouy-app -n argocd

# Manual sync
kubectl patch application khbouy-app -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"now"}}}' --type merge

# Or use ArgoCD CLI
argocd app sync khbouy-app
```

## Cleanup

To remove everything:

```bash
bash p3/scripts/cleanup.sh
```

This will delete the K3d cluster and all associated resources.

## Advanced Topics

### Custom Application

If you want to use your own application instead of `wil42/playground`:

1. Create a public Docker Hub repository
2. Build and push your Docker image with tags `v1` and `v2`
3. Update `p3/confs/deployment.yaml` with your image URL
4. Push the updated manifest to GitHub
5. Argo CD will automatically detect and deploy the new image

### Namespace Management

- **argocd**: Dedicated to Argo CD components
- **dev**: Contains the deployed application
- Both are created automatically by the setup scripts

### GitOps Workflow

The flow is:
1. You modify `deployment.yaml` in GitHub
2. Argo CD periodically checks the repository (default: 3 minutes)
3. When changes are detected, Argo CD syncs the cluster state
4. Application is updated automatically

## References

- [K3d Documentation](https://k3d.io/)
- [K3s Documentation](https://docs.k3s.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
