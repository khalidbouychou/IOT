# Project Requirements

## System Requirements

### Hardware
| Requirement | Part 1 | Part 2 | Part 3 | Bonus | Total |
|-------------|--------|--------|--------|-------|-------|
| RAM | 2GB | 2GB | 4GB | 8GB | 16GB |
| CPU Cores | 2 | 2 | 2 | 4 | 8+ |
| Disk Space | 20GB | 20GB | 10GB | 50GB | 100GB |

### Software
- **Operating System**: Linux (Ubuntu 20.04+) or macOS
- **Vagrant**: 2.3.0 or higher
- **VirtualBox**: 7.0 or higher
- **Docker**: Latest stable (for Part 3 & Bonus)
- **Git**: 2.30+
- **curl/wget**: For downloading files

## Part 1 Requirements

### Objectives
- ✅ Set up 2 Vagrant VMs
- ✅ Install K3s in server mode on first VM
- ✅ Install K3s in agent mode on second VM
- ✅ Configure SSH passwordless access
- ✅ Set up proper networking

### Specifications
- **VM Names**: khbouyS, khbouyW
- **IP Addresses**: 192.168.56.110, 192.168.56.111
- **K3s Version**: Latest stable
- **SSH Access**: Passwordless required

### Success Criteria
```bash
kubectl get nodes
# Output:
# khbouyS   Ready   control-plane,master   v1.xx.x
# khbouyW   Ready   <none>                 v1.xx.x
```

## Part 2 Requirements

### Objectives
- ✅ Deploy single K3s server VM
- ✅ Create 3 web applications
- ✅ Configure Ingress for routing
- ✅ Set up application replicas

### Application Setup
| Application | Replicas | Port | Host |
|-------------|----------|------|------|
| App 1 | 1 | 80 | app1.com |
| App 2 | 3 | 80 | app2.com |
| App 3 | 1 | 80 | default |

### Networking
- **VM IP**: 192.168.56.110
- **Host**: app1.com, app2.com
- **Routing**: Based on HTTP Host header

### Success Criteria
```bash
# Access applications
curl http://app1.com  # App 1
curl http://app2.com  # App 2
curl http://192.168.56.110  # App 3

# Check replicas
kubectl get pods -l app=app2
# Output: 3 running pods
```

## Part 3 Requirements

### Objectives
- ✅ Install and configure K3d locally
- ✅ Set up Argo CD for GitOps
- ✅ Create GitHub repository
- ✅ Implement continuous deployment
- ✅ Test version switching

### Namespaces
| Namespace | Purpose |
|-----------|---------|
| argocd | Argo CD components |
| dev | Deployed application |

### Version Management
- **v1**: Initial version (wil42/playground:v1)
- **v2**: Updated version (wil42/playground:v2)
- **Tagging**: Semantic versioning
- **Registry**: Docker Hub

### Success Criteria
```bash
# Argo CD running
kubectl get pods -n argocd

# Application deployed
kubectl get pods -n dev

# Access application
curl http://localhost:8888/
# Output: {"status":"ok", "message": "v1"}

# After updating to v2
curl http://localhost:8888/
# Output: {"status":"ok", "message": "v2"}
```

## Bonus Requirements

### Objectives
- ✅ Deploy local GitLab instance
- ✅ Configure GitLab CI/CD
- ✅ Integrate with Argo CD
- ✅ Set up GitLab Runner
- ✅ Create complete CI/CD pipeline
- ✅ Support DigitalOcean deployment

### Components
| Component | Type | Purpose |
|-----------|------|---------|
| GitLab | Container | Repository & Registry |
| Argo CD | Container | GitOps Controller |
| Runner | Container | CI/CD Execution |
| PostgreSQL | Database | GitLab Backend |
| Redis | Cache | Performance |
| MinIO | Storage | Artifacts |

### Namespaces
| Namespace | Purpose |
|-----------|---------|
| gitlab | GitLab + Registry |
| argocd | Argo CD |
| gitlab-runner | CI/CD Runners |
| dev | Deployed application |

### Resources Required
- **Memory**: 8GB minimum
- **CPU**: 4 cores minimum
- **Disk**: 50GB minimum
- **Agents**: 3 K3d agents

### Success Criteria
```bash
# All namespaces exist
kubectl get namespace

# GitLab accessible
http://localhost

# Argo CD connected to GitLab
kubectl get application -n argocd

# Application auto-deployed
kubectl get pods -n dev

# Version switching works
# Update GitHub → Auto-sync → App updated
```

## Digital Ocean Support (Bonus)

### Cluster Specifications
- **Provider**: DigitalOcean Kubernetes (DOKS)
- **Node Pool**: 2-3 nodes
- **Machine Size**: 4GB RAM minimum per node
- **Storage**: 50GB minimum

### Configuration
- **HTTPS**: Proper SSL certificates
- **Domain**: Custom domain required
- **Load Balancer**: DigitalOcean LB
- **Managed Database**: Option for production

## Deliverables

### Repository Structure
```
/
├── p1/
│   ├── Vagrantfile
│   ├── scripts/
│   └── confs/
├── p2/
│   ├── Vagrantfile
│   ├── scripts/
│   └── confs/
├── p3/
│   ├── scripts/
│   └── confs/
├── bonus/
│   ├── Vagrantfile
│   ├── scripts/
│   └── confs/
├── README.md
├── SETUP_GUIDE.md
├── REQUIREMENTS.md
└── Makefile
```

### Documentation
- ✅ README.md - Project overview
- ✅ SETUP_GUIDE.md - Detailed setup instructions
- ✅ REQUIREMENTS.md - This file
- ✅ Part-specific READMEs
- ✅ Script documentation

### Configuration Files
- ✅ Vagrantfiles for each part
- ✅ Shell scripts for automation
- ✅ Kubernetes manifests (YAML)
- ✅ Helm values files
- ✅ Configuration files

## Evaluation Criteria

### Part 1 (30%)
- [ ] 2 VMs created with correct names
- [ ] Correct IP addresses (192.168.56.110, 111)
- [ ] K3s server running on first VM
- [ ] K3s agent running on second VM
- [ ] Passwordless SSH access
- [ ] Nodes in Ready state

### Part 2 (30%)
- [ ] Single VM with correct IP
- [ ] 3 applications deployed
- [ ] App 1 & 3: 1 replica each
- [ ] App 2: 3 replicas
- [ ] Ingress routing by host
- [ ] All applications accessible

### Part 3 (30%)
- [ ] K3d cluster running
- [ ] Argo CD deployed and accessible
- [ ] GitHub repository created
- [ ] Application auto-deployed
- [ ] Version switching works
- [ ] GitOps workflow functional

### Bonus (10%)
- [ ] GitLab deployed locally
- [ ] GitLab Runner configured
- [ ] CI/CD pipeline working
- [ ] GitHub/GitLab integration
- [ ] DigitalOcean deployment script provided
- [ ] Complete automation

## Testing Checklist

### Part 1
```bash
[ ] vagrant up successful
[ ] Both VMs running
[ ] kubectl get nodes shows 2 Ready nodes
[ ] SSH passwordless access works
[ ] K3s services running
```

### Part 2
```bash
[ ] vagrant up successful
[ ] VM running at 192.168.56.110
[ ] 3 applications deployed
[ ] kubectl get pods shows correct replicas
[ ] curl app1.com returns App 1
[ ] curl app2.com returns App 2
[ ] curl 192.168.56.110 returns App 3
[ ] Ingress configured correctly
```

### Part 3
```bash
[ ] K3d cluster created
[ ] kubectl get nodes shows agents
[ ] Argo CD pods running
[ ] GitHub repository created with manifests
[ ] Application deployed in dev namespace
[ ] curl localhost:8888 returns v1
[ ] GitHub update triggers sync
[ ] Application updates to v2
[ ] curl localhost:8888 returns v2
```

### Bonus
```bash
[ ] vagrant up successful
[ ] K3d cluster created
[ ] GitLab accessible at localhost
[ ] Can login with root/password
[ ] GitLab repository created
[ ] Argo CD syncing from GitLab
[ ] Runner executing jobs
[ ] Application auto-deployed
[ ] Version switching works
```

## Performance Benchmarks

### Expected Startup Times
- Part 1 VM: 3-5 minutes
- Part 2 VM: 3-5 minutes
- Part 3 K3d: 1-2 minutes
- Bonus VM: 5-10 minutes

### Resource Usage
- Part 1: 2GB RAM, 20GB Disk
- Part 2: 2GB RAM, 20GB Disk
- Part 3: 4GB RAM, 10GB Disk
- Bonus: 8GB RAM, 50GB Disk

## Monitoring Commands

### Check VM Status
```bash
cd p1 && vagrant status
cd p2 && vagrant status
```

### Check K3d Cluster
```bash
k3d cluster list
k3d cluster logs khbouy
```

### Check Kubernetes Resources
```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

### Check Resource Usage
```bash
kubectl top nodes
kubectl top pods -A
docker stats
```

## Troubleshooting Checklist

- [ ] Check system resources (RAM, disk, CPU)
- [ ] Verify software versions
- [ ] Check network connectivity
- [ ] Review logs for errors
- [ ] Verify DNS resolution
- [ ] Check port availability
- [ ] Review firewall settings
- [ ] Test with minimal setup first
