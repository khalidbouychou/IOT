    #!/bin/bash
set -e

echo "=== Hetzner Cloud Setup ==="
echo ""
echo "Hetzner Cloud features:"
echo "  - Affordable VPS starting at €1/month"
echo "  - Excellent performance"
echo "  - No credit card hidden charges"
echo ""

# Check if hcloud CLI is installed
if ! command -v hcloud &> /dev/null; then
    echo "Installing Hetzner Cloud CLI..."
    wget https://github.com/hetznercloud/cli/releases/download/v1.36.2/hcloud-linux-amd64.tar.gz
    tar xzf hcloud-linux-amd64.tar.gz
    sudo mv hcloud /usr/local/bin
    rm hcloud-linux-amd64.tar.gz
fi

echo ""
echo "Step 1: Create Hetzner API token"
echo "Visit: https://console.hetzner.cloud/projects"
echo "Create an API token in project settings"
read -p "Enter API token: " HCLOUD_TOKEN
export HCLOUD_TOKEN

echo ""
echo "Step 2: Create SSH key"
hcloud ssh-key create --name khbouy --public-key-from-file ~/.ssh/id_rsa.pub

echo ""
echo "Step 3: Create Hetzner Cloud network"
NETWORK=$(hcloud network create --name khbouy-net --ip-range 10.0.0.0/8 --format json | jq -r '.network.id')
echo "Network created: $NETWORK"

echo ""
echo "Step 4: Create servers for K3s cluster"
read -p "Enter number of servers (e.g., 3): " SERVER_COUNT

for i in $(seq 1 "$SERVER_COUNT"); do
    echo "Creating server $i..."
    hcloud server create \
      --name "khbouy-k3s-$i" \
      --type cx21 \
      --image ubuntu-22.04 \
      --ssh-key khbouy \
      --network khbouy-net
done

echo ""
echo "Step 5: Install K3s on servers"
echo "Get server IPs:"
hcloud server list

echo ""
echo "Connect to first server and install K3s server:"
echo "  curl -sfL https://get.k3s.io | sh -"
echo ""
echo "Connect to other servers and install K3s agents:"
echo "  curl -sfL https://get.k3s.io | K3S_URL=https://<server-ip>:6443 K3S_TOKEN=<token> sh -"
echo ""

echo "Step 6: Get kubeconfig"
echo "From server:"
echo "  cat /etc/rancher/k3s/k3s.yaml"
echo "Then copy and save locally"

echo ""
echo "Deployment complete!"
echo ""
echo "Clean up when done:"
echo "hcloud server delete khbouy-k3s-1 khbouy-k3s-2 khbouy-k3s-3"
echo "hcloud network delete $NETWORK"
