
#!/bin/bash
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
      sudo EXTERNAL_URL="http://192.168.56.120" apt-get install -y gitlab-ce
      echo "prometheus['enable'] = false" | sudo tee -a /etc/gitlab/gitlab.rb
      sudo gitlab-ctl reconfigure