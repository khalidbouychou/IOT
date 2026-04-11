#!/bin/bash
curl -sfL https://get.k3s.io | sh -

# Save token
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token

# Enable kubectl
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc