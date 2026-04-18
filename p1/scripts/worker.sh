#!/bin/bash

# TOKEN=$(cat /vagrant/token)

# curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -

# Wait for the token to appear
while [ ! -f /vagrant/scripts/node-token ]; do sleep 2; done
export K3S_TOKEN=$(cat /vagrant/scripts/node-token)
export K3S_URL=https://192.168.56.110:6443
export INSTALL_K3S_EXEC="--node-ip=192.168.56.111"
curl -sfL https://get.k3s.io | sh -