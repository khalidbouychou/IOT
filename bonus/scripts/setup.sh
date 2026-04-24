#!/bin/bash

# 1. Update system
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

# 2. Add GitLab repository and install
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
# EXTERNAL_URL ensures GitLab knows its own IP
sudo EXTERNAL_URL="http://192.168.56.120" apt-get install -y gitlab-ce

# 3. Disable heavy monitoring to save RAM on the 8GB iMac
echo "prometheus['enable'] = false" >> /etc/gitlab/gitlab.rb
echo "grafana['enable'] = false" >> /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure