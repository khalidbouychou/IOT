#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y net-tools curl

 # Install K3s server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 192.168.56.110 --tls-san 192.168.56.110" sh -
  # Replace the server IP in the kubeconfig file
sudo sed -i 's/127.0.0.1/192.168.56.110/' /etc/rancher/k3s/k3s.yaml
 # Configure kubectl access
sudo  echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /root/.bash 
 # Get node token
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token