#!/bin/bash
set -e

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -

sleep 5

mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config

ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "K3s installed successfully"
