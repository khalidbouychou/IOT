#!/bin/bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --tls-san 192.168.56.110" sh -
cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
chmod 644 /vagrant/node-token