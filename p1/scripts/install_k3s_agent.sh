#!/bin/bash
set -e

# Get token from server
TOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.56.110 "cat /var/lib/rancher/k3s/server/node-token" 2>/dev/null)

# Install K3s in agent mode
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="$TOKEN" sh -

# Wait for K3s to be ready
sleep 5

echo "K3s Agent installed successfully"
