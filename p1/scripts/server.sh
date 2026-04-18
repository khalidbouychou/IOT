#!/bin/bash
# curl -sfL https://get.k3s.io | sh -

# # Save token
# sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token

# # Enable kubectl
# echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc


export INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --bind-address=192.168.56.110 --node-ip=192.168.56.110"
curl -sfL https://get.k3s.io | sh -
# Save the token to a shared folder so the worker can read it
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/scripts/node-token