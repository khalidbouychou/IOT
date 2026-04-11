#!/bin/bash
set -e

echo "=== Oracle Cloud Always-Free Setup ==="
echo ""
echo "Oracle Cloud Free Tier includes:"
echo "  - 2 AMD vCPUs (compute)"
echo "  - 12 GB RAM"
echo "  - 100 GB storage"
echo "  - ALWAYS FREE - never expires!"
echo ""

# Check if OCI CLI is installed
if ! command -v oci &> /dev/null; then
    echo "Installing Oracle Cloud CLI..."
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
fi

echo ""
echo "Step 1: Setup Oracle Cloud CLI"
oci setup config

echo ""
echo "Step 2: Create compartment"
read -p "Enter compartment name (e.g., khbouy-compartment): " COMPARTMENT_NAME

COMPARTMENT_ID=$(oci iam compartment create \
  --name "$COMPARTMENT_NAME" \
  --description "Inception of Things Project" \
  --query 'data.id' \
  --raw-output)

echo "Compartment created: $COMPARTMENT_ID"

echo ""
echo "Step 3: Create Container Registry"
REGISTRY=$(oci artifacts container repository create \
  --display-name khbouy-iot \
  --compartment-id "$COMPARTMENT_ID" \
  --query 'data."image-url"' \
  --raw-output)

echo "Container Registry created: $REGISTRY"

echo ""
echo "Step 4: Create Kubernetes Cluster"
echo "This will create an OKE cluster on Oracle Cloud"
echo ""
echo "Run the following in Oracle Cloud Console:"
echo "1. Go to: Containers → Kubernetes Clusters"
echo "2. Click 'Create Cluster'"
echo "3. Select 'Quick Create'"
echo "4. Configure as per your needs"
echo ""

echo "Step 5: Download kubeconfig"
read -p "Enter your cluster ID: " CLUSTER_ID

mkdir -p ~/.kube
oci ce cluster create-kubeconfig \
  --cluster-id "$CLUSTER_ID" \
  --file ~/.kube/oracle-kubeconfig.yaml

echo ""
echo "Setup complete!"
echo "Kubeconfig saved to: ~/.kube/oracle-kubeconfig.yaml"
echo ""
echo "Next steps:"
echo "1. export KUBECONFIG=~/.kube/oracle-kubeconfig.yaml"
echo "2. Deploy GitLab and Argo CD using Helm"
echo "3. Your resources are FREE forever (within always-free tier)"
