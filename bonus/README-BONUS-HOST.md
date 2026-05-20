# Bonus Part: Host-Based Setup (No Vagrant)

## Overview

This refactored bonus part runs entirely on your Ubuntu machine with all tools and cache stored in `~/Trashbonus/`. It includes:

- **k3d cluster** (lightweight Kubernetes in Docker)
- **Argo CD** (GitOps continuous deployment)
- **GitLab CE** (Docker container for self-hosted Git)

## Architecture

```
Your Ubuntu Machine:
  ├─ ~/Trashbonus/
  │   ├─ bin/          (kubectl, k3d executables)
  │   ├─ docker/       (Docker config)
  │   └─ gitlab/       (GitLab persistent volumes)
  │
  ├─ k3d cluster 'bonus-cluster' (running in Docker)
  │   ├─ Argo CD namespace
  │   ├─ dev namespace
  │   └─ gitlab namespace
  │
  └─ Docker: GitLab CE container (mapped to port 8929)
```

## Quick Start

### 1. Run One Script

```bash
cd /path/to/IOT/bonus
chmod +x setup_bonus_host.sh clean_bonus.sh
sh setup_bonus_host.sh
```

This will:

- Create k3d cluster
- Create namespaces `argocd`, `dev`, `gitlab`
- Install Argo CD
- Start GitLab in Docker
- Generate and apply `confs/application-bonus.yaml`
- Print credentials and minimal manual steps

**Expected output:**

```
✅ BONUS SETUP COMPLETE
📋 SERVICES:
   Argo CD UI:  http://localhost:8080
   GitLab UI:   http://<YOUR_IP>:8929
🔐 CREDENTIALS:
   Argo CD  → User: admin | Pass: <PASSWORD>
   GitLab   → User: root  | Pass: <PASSWORD>
```

### 2. Create GitLab Project

1. Open `http://<YOUR_IP>:8929` in browser
2. Log in as root with the password from above
3. Create a **PUBLIC** project named `iot-bonus`

### 3. Push Code to GitLab

```bash
cd /path/to/IOT/bonus
git init
git remote add bonus http://<YOUR_IP>:8929/root/iot-bonus.git
git add deployment.yaml
git commit -m "bonus"
git push bonus master
# When prompted: username=root, password=<GitLab password from setup>
```

### 4. View Argo CD UI (in separate terminal)

```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Visit: https://localhost:8080
# User: admin
# Password: <from setup output>
# (Accept the self-signed certificate warning)
```

### 5. Demo: GitOps in Action

1. Edit `deployment.yaml` on GitLab web UI (or push a new commit)
2. Change image from `v1` to `v2` (if using wil42/playground)
3. Watch Argo CD auto-detect and sync
4. Test: `curl http://localhost:8888` → should now show `v2`

---

## Requirements

Install these once on your machine:

- Docker
- kubectl
- k3d
- curl

---

## Troubleshooting

### Docker commands not working

**Fix:** Make sure your user has access to Docker daemon.

```bash
docker ps
```

### GitLab taking too long to start

**Normal:** GitLab needs 2-3 minutes to initialize. Monitor with:

```bash
docker logs -f gitlab-bonus
```

### Argo CD can't reach GitLab repo

**Possible issue:** k3d containers use `host.docker.internal` to reach the host on macOS, but on Linux use the actual host IP.

**Fix:** Edit `bonus/confs/application-bonus.yaml` and replace:

```yaml
repoURL: "http://<YOUR_HOST_IP>:8929/root/iot-bonus.git"
```

where `<YOUR_HOST_IP>` is output from `hostname -I | awk '{print $1}'`

Then reapply:

```bash
kubectl apply -f bonus/confs/application-bonus.yaml
```

### Need to check cluster/services status

```bash
# k3d clusters
k3d cluster list

# Argo CD
kubectl get all -n argocd

# GitLab container
docker ps | grep gitlab

# Deployed apps in dev namespace
kubectl get all -n dev
```

### Need to restart everything

```bash
# Pause/resume k3d
k3d cluster stop bonus-cluster
k3d cluster start bonus-cluster

# Restart GitLab
docker restart gitlab-bonus
```

---

## Cleanup

Remove all services and free up disk space:

```bash
sh clean_bonus.sh
```

This removes:

- k3d cluster
- GitLab Docker container
- `~/Trashbonus/` directory (all cached data)
- kubeconfig

Docker and kubectl remain installed on your system.

---

## Files Overview

| File                           | Purpose                                          |
| ------------------------------ | ------------------------------------------------ |
| `setup_bonus_host.sh`          | Start k3d, Argo CD, and GitLab; print next steps |
| `clean_bonus.sh`               | Remove all services and cleanup                  |
| `confs/application-bonus.yaml` | Argo CD manifest pointing to local GitLab        |
| `README-BONUS-HOST.md`         | This file                                        |

---

## Comparison: Vagrant vs Host-Based

| Aspect      | Vagrant VM                    | Host-Based                  |
| ----------- | ----------------------------- | --------------------------- |
| Setup       | More complex (VirtualBox VMs) | Simpler (Docker containers) |
| Resources   | Higher (separate OS per VM)   | Lower (shares host OS)      |
| Speed       | Slower VM boot/provisioning   | Faster startup              |
| Storage     | Spreads across system         | All in `~/Trashbonus/`      |
| Cleanup     | `vagrant destroy`             | `clean_bonus.sh`            |
| Portability | VirtualBox required           | Only Docker + CLI tools     |

---

## Next: GitOps Workflow

Once setup is complete:

1. Any commit to `iot-bonus` repo on GitLab is detected by Argo CD
2. Argo automatically syncs the cluster to match the repo
3. This is **GitOps** — git is the source of truth, not kubectl commands

Try editing `deployment.yaml` and pushing to test!
