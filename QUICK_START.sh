#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Inception-of-Things - Quick Start${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Vagrant
if ! command -v vagrant &> /dev/null; then
    echo -e "${RED}✗ Vagrant not installed${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Vagrant installed${NC}"
fi

# Check VirtualBox
if ! command -v vboxmanage &> /dev/null; then
    echo -e "${RED}✗ VirtualBox not installed${NC}"
    exit 1
else
    echo -e "${GREEN}✓ VirtualBox installed${NC}"
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not installed${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Git installed${NC}"
fi

# Check available resources
echo ""
echo -e "${YELLOW}Checking system resources...${NC}"

# Check RAM
RAM=$(free -h | awk 'NR==2 {print $2}')
echo -e "${GREEN}✓ Available RAM: $RAM${NC}"

# Check disk
DISK=$(df -h / | awk 'NR==2 {print $4}')
echo -e "${GREEN}✓ Available Disk: $DISK${NC}"

echo ""
echo -e "${YELLOW}Select which part to start:${NC}"
echo "1. Part 1 (K3s 2-Node Cluster)"
echo "2. Part 2 (K3s with 3 Applications)"
echo "3. Part 3 (K3d + Argo CD)"
echo "4. Bonus (GitLab + K3d + Argo CD)"
echo "5. Clean Everything"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo -e "${YELLOW}Starting Part 1...${NC}"
        cd p1
        vagrant up
        echo -e "${GREEN}Part 1 started successfully!${NC}"
        echo "SSH into server: vagrant ssh khbouyS"
        ;;
    2)
        echo -e "${YELLOW}Starting Part 2...${NC}"
        cd p2
        vagrant up
        echo -e "${GREEN}Part 2 started successfully!${NC}"
        echo "Access at: 192.168.56.110"
        ;;
    3)
        echo -e "${YELLOW}Setting up Part 3...${NC}"
        
        # Check Docker
        if ! command -v docker &> /dev/null; then
            echo -e "${RED}Docker not installed. Installing...${NC}"
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
        fi
        
        bash p3/scripts/setup_k3d.sh
        bash p3/scripts/setup_argocd.sh
        
        echo -e "${GREEN}Part 3 setup complete!${NC}"
        echo "Next steps:"
        echo "1. Create GitHub repository: khbouy-iot"
        echo "2. Push p3/confs/deployment.yaml to GitHub"
        echo "3. Update p3/confs/argocd-app.yaml with your repo URL"
        echo "4. Run: kubectl apply -f p3/confs/argocd-app.yaml"
        ;;
    4)
        echo -e "${YELLOW}Starting Bonus...${NC}"
        cd bonus
        vagrant up
        echo -e "${GREEN}Bonus started successfully!${NC}"
        echo "Run: bash scripts/get_gitlab_password.sh"
        echo "Access GitLab at: http://localhost"
        ;;
    5)
        echo -e "${YELLOW}Cleaning up all resources...${NC}"
        make cleanup
        echo -e "${GREEN}Cleanup complete!${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}For detailed information, see SETUP_GUIDE.md${NC}"
