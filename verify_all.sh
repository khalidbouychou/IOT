#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Inception-of-Things - Complete Verification ===${NC}"
echo ""

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓ $1 installed${NC}"
        return 0
    else
        echo -e "${RED}✗ $1 not installed${NC}"
        return 1
    fi
}

# Check prerequisites
echo -e "${YELLOW}Prerequisites:${NC}"
check_command vagrant || true
check_command vboxmanage || true
check_command git || true
check_command docker || true
check_command kubectl || true
check_command k3d || true
check_command helm || true
echo ""

# Check Part 1
echo -e "${YELLOW}Part 1 (K3s 2-Node Cluster):${NC}"
if [ -d "p1" ]; then
    cd p1
    if vagrant status | grep -q "running"; then
        echo -e "${GREEN}✓ Part 1 VMs running${NC}"
        vagrant ssh khbouyS -c "kubectl get nodes" 2>/dev/null && echo -e "${GREEN}✓ kubectl accessible${NC}" || echo -e "${RED}✗ kubectl not accessible${NC}"
    else
        echo -e "${YELLOW}○ Part 1 VMs not running${NC}"
    fi
    cd ..
else
    echo -e "${RED}✗ Part 1 directory not found${NC}"
fi
echo ""

# Check Part 2
echo -e "${YELLOW}Part 2 (K3s with Applications):${NC}"
if [ -d "p2" ]; then
    cd p2
    if vagrant status | grep -q "running"; then
        echo -e "${GREEN}✓ Part 2 VM running${NC}"
        vagrant ssh khbouyS -c "kubectl get pods" 2>/dev/null && echo -e "${GREEN}✓ Applications deployed${NC}" || echo -e "${RED}✗ Applications not accessible${NC}"
    else
        echo -e "${YELLOW}○ Part 2 VM not running${NC}"
    fi
    cd ..
else
    echo -e "${RED}✗ Part 2 directory not found${NC}"
fi
echo ""

# Check Part 3
echo -e "${YELLOW}Part 3 (K3d + Argo CD):${NC}"
if k3d cluster list | grep -q "khbouy"; then
    echo -e "${GREEN}✓ K3d cluster running${NC}"
    
    KUBECONFIG=$(k3d kubeconfig get khbouy)
    export KUBECONFIG
    
    if kubectl get namespace argocd &> /dev/null; then
        echo -e "${GREEN}✓ Argo CD namespace exists${NC}"
        kubectl get pods -n argocd -q && echo -e "${GREEN}✓ Argo CD pods running${NC}" || echo -e "${YELLOW}○ Argo CD pods not ready${NC}"
    else
        echo -e "${YELLOW}○ Argo CD not installed${NC}"
    fi
    
    if kubectl get namespace dev &> /dev/null; then
        echo -e "${GREEN}✓ Dev namespace exists${NC}"
    fi
else
    echo -e "${YELLOW}○ K3d cluster not running${NC}"
fi
echo ""

# Check Bonus
echo -e "${YELLOW}Bonus (GitLab + K3d + Argo CD):${NC}"
if k3d cluster list | grep -q "khbouy-gitlab"; then
    echo -e "${GREEN}✓ Bonus K3d cluster running${NC}"
    
    KUBECONFIG=$(k3d kubeconfig get khbouy-gitlab)
    export KUBECONFIG
    
    if kubectl get namespace gitlab &> /dev/null; then
        echo -e "${GREEN}✓ GitLab namespace exists${NC}"
        kubectl get pods -n gitlab -q | grep gitlab && echo -e "${GREEN}✓ GitLab running${NC}" || echo -e "${YELLOW}○ GitLab not ready${NC}"
    else
        echo -e "${YELLOW}○ GitLab not installed${NC}"
    fi
    
    if kubectl get namespace argocd &> /dev/null; then
        echo -e "${GREEN}✓ Argo CD namespace exists${NC}"
    fi
else
    echo -e "${YELLOW}○ Bonus cluster not running${NC}"
fi
echo ""

echo -e "${GREEN}=== Verification Complete ===${NC}"
