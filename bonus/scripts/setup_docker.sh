#!/bin/bash
set -e

echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

echo "Docker installed successfully"
