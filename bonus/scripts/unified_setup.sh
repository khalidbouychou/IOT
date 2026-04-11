#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Inception of Things - Universal Deployment Script        ║"
echo "║            Choose your deployment platform                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Function to detect local environment
detect_environment() {
    if command -v vagrant &> /dev/null && [ -f Vagrantfile ]; then
        echo "local_vagrant"
    elif command -v k3d &> /dev/null; then
        echo "local_k3d"
    elif command -v docker &> /dev/null; then
        echo "docker_available"
    else
        echo "none"
    fi
}

# Function to show platform options
show_platforms() {
    echo "Available deployment platforms:"
    echo ""
    echo "LOCAL PLATFORMS:"
    echo "  1) Local Vagrant + VirtualBox (Development)"
    echo "  2) Local K3d + Docker (Quick testing)"
    echo ""
    echo "CLOUD PLATFORMS (Free/Cheap):"
    echo "  3) DigitalOcean ($5-6/month with credits)"
    echo "  4) AWS EKS (12-month free tier)"
    echo "  5) Google Cloud Platform ($300 free credit)"
    echo "  6) Oracle Cloud (Always-free tier)"
    echo "  7) Linode LKE (Simple pricing)"
    echo "  8) Hetzner Cloud (€1+ VPS)"
    echo ""
    echo "CI/CD PLATFORMS:"
    echo "  9) GitHub Actions (FREE for public repos)"
    echo " 10) Railway.app (FREE tier: $5/month)"
    echo ""
    echo " 0) Exit"
    echo ""
}

# Function to validate requirements
validate_requirements() {
    local platform=$1
    local missing=()
    
    case $platform in
        1|2)  # Local deployments
            command -v vagrant &> /dev/null || missing+=("vagrant")
            command -v docker &> /dev/null || missing+=("docker")
            ;;
        3)  # DigitalOcean
            command -v doctl &> /dev/null || missing+=("doctl")
            [ -z "$DO_API_TOKEN" ] && missing+=("DO_API_TOKEN")
            ;;
        4)  # AWS
            command -v aws &> /dev/null || missing+=("aws-cli")
            command -v eksctl &> /dev/null || missing+=("eksctl")
            ;;
        5)  # GCP
            command -v gcloud &> /dev/null || missing+=("gcloud")
            ;;
        6)  # Oracle
            command -v oci &> /dev/null || missing+=("oci-cli")
            ;;
        7)  # Linode
            command -v linode-cli &> /dev/null || missing+=("linode-cli")
            ;;
        8)  # Hetzner
            command -v hcloud &> /dev/null || missing+=("hcloud")
            ;;
        9)  # GitHub Actions
            [ -d ".git" ] || missing+=("git-repository")
            ;;
        10) # Railway
            command -v npm &> /dev/null || missing+=("npm")
            ;;
    esac
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "❌ Missing requirements: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Main menu loop
while true; do
    show_platforms
    read -p "Select platform (0-10): " choice
    
    case $choice in
        0)
            echo "Exiting..."
            exit 0
            ;;
        1)
            echo "Deploying to Local Vagrant..."
            if validate_requirements 1; then
                cd ../p1 && vagrant up
            fi
            ;;
        2)
            echo "Deploying to Local K3d..."
            if validate_requirements 2; then
                bash scripts/setup_k3d.sh
                bash scripts/setup_argocd_gitlab.sh
            fi
            ;;
        3)
            echo "Deploying to DigitalOcean..."
            if validate_requirements 3; then
                bash scripts/setup_digital_ocean.sh
            fi
            ;;
        4)
            echo "Deploying to AWS EKS..."
            if validate_requirements 4; then
                bash scripts/setup_aws.sh
            fi
            ;;
        5)
            echo "Deploying to Google Cloud..."
            if validate_requirements 5; then
                bash scripts/setup_gcp.sh
            fi
            ;;
        6)
            echo "Deploying to Oracle Cloud..."
            if validate_requirements 6; then
                bash scripts/setup_oracle_cloud.sh
            fi
            ;;
        7)
            echo "Deploying to Linode..."
            if validate_requirements 7; then
                bash scripts/setup_linode.sh
            fi
            ;;
        8)
            echo "Deploying to Hetzner Cloud..."
            if validate_requirements 8; then
                bash scripts/setup_hetzner.sh
            fi
            ;;
        9)
            echo "Setting up GitHub Actions..."
            if validate_requirements 9; then
                bash scripts/setup_github_actions.sh
            fi
            ;;
        10)
            echo "Setting up Railway.app..."
            if validate_requirements 10; then
                bash scripts/setup_railway.sh
            fi
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
