#!/bin/bash



export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://192.168.56.120" apt-get install -y gitlab-ce
# Optimization for 8GB RAM
echo "prometheus['enable'] = false" | sudo tee -a /etc/gitlab/gitlab.rb
echo "puma['worker_processes'] = 0" | sudo tee -a /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure