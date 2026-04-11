# Complete Deployment Guide

## Quick Start

### Option 1: Local Development (Recommended for learning)

```bash
cd /goinfre/khbouych/IOT/bonus
vagrant up
```

### Option 2: Interactive Setup

```bash
bash scripts/unified_setup.sh
```

---

## Platform Comparison

| Platform | Cost | Setup Time | Best For | Free Tier |
|----------|------|-----------|----------|-----------|
| **Local Vagrant** | $0 | 10 mins | Learning, Development | ✅ Free |
| **Local K3d** | $0 | 5 mins | Quick testing | ✅ Free |
| **DigitalOcean** | $5-6/mo | 15 mins | Production-like | ✅ $5-10 credit |
| **AWS EKS** | $0.10/cluster + compute | 20 mins | Enterprise | ✅ 12-month free |
| **Google Cloud** | Varies | 20 mins | Integration | ✅ $300 credit |
| **Oracle Cloud** | $0 | 25 mins | Cost-effective | ✅ Always free |
| **Linode LKE** | $10+/mo | 15 mins | Simplicity | ✅ $100 credit |
| **Hetzner** | €1+/mo | 20 mins | Budget | ❌ No free tier |
| **GitHub Actions** | $0 | 5 mins | CI/CD only | ✅ Free for public |
| **Railway** | $5/mo | 10 mins | Simple apps | ✅ $5 credit |

---

## Detailed Setup Instructions

### 1. Local Vagrant (Best for learning)

**Requirements:**
- VirtualBox installed
- 6GB RAM available
- 10GB disk space

**Setup:**
```bash
cd bonus
vagrant up
```

**Verify:**
```bash
bash scripts/verify_bonus_setup.sh
```

**Access Services:**
- GitLab: http://localhost
- Argo CD: https://localhost:8080 (after port-forward)
- Application: http://localhost:8888

---

### 2. Local K3d (Quick testing)

**Requirements:**
- Docker installed
- 4GB RAM available

**Setup:**
```bash
bash scripts/setup_k3d.sh
bash scripts/setup_argocd_gitlab.sh
```

**Verify:**
```bash
kubectl get pods -A
```

---

### 3. DigitalOcean (Production-ready)

**Prerequisites:**
- DigitalOcean account
- API token created
- Domain registered (optional)

**Setup:**
```bash
export DO_API_TOKEN="your_token_here"
bash scripts/setup_digital_ocean.sh
```

**Estimated Cost:**
- First month: $0 (free credits)
- Ongoing: $5-6/month

**Benefits:**
- Simple to use
- Good documentation
- Fast deployment
- Affordable pricing

---

### 4. AWS EKS

**Prerequisites:**
- AWS account
- AWS CLI configured
- Appropriate IAM permissions

**Setup:**
```bash
bash scripts/setup_aws.sh
```

**Estimated Cost:**
- First 12 months: Mostly free (with compute)
- Ongoing: ~$0.10/cluster/hour + compute

**Delete after testing:**
```bash
eksctl delete cluster --name khbouy-eks --region us-east-1
```

---

### 5. Google Cloud Platform

**Prerequisites:**
- GCP project
- gcloud CLI configured
- Billing enabled

**Setup:**
```bash
bash scripts/setup_gcp.sh
```

**Estimated Cost:**
- First 3 months: $300 free credit
- Ongoing: ~$30-50/month

---

### 6. Oracle Cloud (Always-Free)

**Prerequisites:**
- Oracle Cloud account (free)
- OCI CLI configured

**Setup:**
```bash
bash scripts/setup_oracle_cloud.sh
```

**Estimated Cost:**
- Always free (within limits)
- No credit card required
- No automatic upgrades

**Free Resources:**
- 2 AMD vCPUs
- 12 GB RAM
- 100 GB storage
- 10 GB outbound data transfer/month

---

### 7. Linode LKE

**Prerequisites:**
- Linode account
- API token
- linode-cli installed

**Setup:**
```bash
bash scripts/setup_linode.sh
```

**Estimated Cost:**
- First month: $0 ($100 free credit)
- Ongoing: $10/month (minimum)

---

### 8. Hetzner Cloud

**Prerequisites:**
- Hetzner account
- API token
- SSH key generated

**Setup:**
```bash
bash scripts/setup_hetzner.sh
```

**Estimated Cost:**
- €1+/month per VPS
- Very affordable

---

### 9. GitHub Actions (CI/CD only)

**Prerequisites:**
- GitHub account
- Public repository

**Setup:**
```bash
bash scripts/setup_github_actions.sh
```

**Features:**
- FREE for public repos
- 2000 minutes/month for private repos
- Runs on GitHub servers

**Workflows Included:**
- Build and push Docker images
- Test Kubernetes manifests
- Deploy to cluster

---

### 10. Railway.app

**Prerequisites:**
- Railway.app account
- GitHub/GitLab account

**Setup:**
```bash
bash scripts/setup_railway.sh
```

**Estimated Cost:**
- First month: $5 free credit
- Ongoing: $5-20/month

**Good For:**
- Simple applications
- Prototype deployments
- Learning

---

## Environment Configuration

### 1. Copy .env template

```bash
cp .env.example .env
```

### 2. Edit .env with your values

```bash
# For DigitalOcean
DO_API_TOKEN=dop_v1_xxxxx
DO_DOMAIN=yourdomain.com

# For GitHub
GITHUB_TOKEN=ghp_xxxxx
GITHUB_REPO_URL=https://github.com/yourname/khbouy-iot

# For GitLab
GITLAB_ADMIN_EMAIL=root@khbouy.local
```

### 3. Load environment

```bash
source .env
```

---

## Common Workflows

### Deploy and Test Locally

```bash
# 1. Start with Vagrant
cd bonus
vagrant up

# 2. Access GitLab
bash scripts/get_gitlab_password.sh

# 3. Create repository and push code

# 4. Configure Argo CD

# 5. Test version switching
```

### Deploy to Production

```bash
# 1. Choose platform
bash scripts/unified_setup.sh

# 2. Select cloud provider (e.g., DigitalOcean)

# 3. Configure domain and SSL

# 4. Setup continuous deployment

# 5. Monitor and maintain
```

### Migrate between platforms

```bash
# 1. Export configuration from old platform
kubectl get all -A -o yaml > backup.yaml

# 2. Setup new platform
bash scripts/setup_<platform>.sh

# 3. Import configuration
kubectl apply -f backup.yaml

# 4. Verify deployment
bash scripts/verify_bonus_setup.sh
```

---

## Troubleshooting

### Common Issues

**Platform not available:**
```bash
# Check prerequisites
bash scripts/setup_<platform>.sh --check

# Install missing tools
bash scripts/setup_<platform>.sh --install-deps
```

**Kubeconfig not found:**
```bash
# For DigitalOcean
doctl kubernetes cluster kubeconfig save <cluster-name>

# For AWS
aws eks update-kubeconfig --name <cluster-name> --region <region>

# For GCP
gcloud container clusters get-credentials <cluster-name> --region <region>
```

**Application not deploying:**
```bash
# Check Argo CD status
kubectl get application -n argocd

# Check pod logs
kubectl logs -n dev -l app=playground

# Force sync
kubectl patch application khbouy-app-gitlab -n argocd \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"now"}}}'
```

---

## Cost Optimization

### Free Options
- ✅ GitHub Actions (public repos)
- ✅ Oracle Cloud Always-Free
- ✅ Local Vagrant/K3d

### Low-Cost Options
- 💰 Railway.app: $5/month
- 💰 DigitalOcean: $5-6/month
- 💰 AWS: $10-20/month

### Using Free Credits
- 💳 DigitalOcean: $5-10 new user credit
- 💳 AWS: 12-month free tier
- 💳 GCP: $300 for 3 months
- 💳 Linode: $100 free credit
- 💳 Railway: $5 free credit

---

## Next Steps

### 1. Start Simple
- Begin with local Vagrant
- Learn Kubernetes concepts
- Practice GitOps workflow

### 2. Move to Cloud
- Try DigitalOcean (cheapest)
- Or Oracle Cloud (free)
- Setup custom domain

### 3. Production Ready
- Enable SSL/TLS
- Setup monitoring
- Configure backups
- Implement security policies

### 4. Advanced Topics
- Multi-cluster setup
- Disaster recovery
- Auto-scaling
- Service mesh

---

## Support and Resources

- **Kubernetes:** https://kubernetes.io/docs/
- **K3s:** https://docs.k3s.io/
- **K3d:** https://k3d.io/
- **Argo CD:** https://argo-cd.readthedocs.io/
- **Helm:** https://helm.sh/docs/
- **GitLab:** https://docs.gitlab.com/
- **DigitalOcean:** https://docs.digitalocean.com/
- **AWS EKS:** https://docs.aws.amazon.com/eks/

