  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install -y net-tools curl
  # Wait until token exists
  while [ ! -f /vagrant/node-token ]
  do
    sleep 2
  done
  TOKEN=$(cat /vagrant/node-token | tr -d '\n')
  # Install K3s agent
  sudo curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -