#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# 1. Install Dependencies
apt-get update
apt-get install -y curl openssh-server ca-certificates tzdata perl

# 2. Add GitLab Repository and Install
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
# EXTERNAL_URL is crucial so GitLab knows its IP
sudo EXTERNAL_URL="http://192.168.56.120" apt-get install -y gitlab-ce

# 3. Optimize for 8GB iMac (Disable heavy features)
# This saves about 1.5GB of RAM
cat <<EOF >> /etc/gitlab/gitlab.rb
puma['worker_processes'] = 0
sidekiq['max_concurrency'] = 5
prometheus['enable'] = false
grafana['enable'] = false
alertmanager['enable'] = false
EOF

# 4. Apply settings
gitlab-ctl reconfigure