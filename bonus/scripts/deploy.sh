#!/bin/bash

# 1. Create the mandatory namespace
echo "Creating gitlab namespace..."
kubectl create namespace gitlab

# 2. Start the GitLab VM
echo "Launching GitLab VM... this will take a while."
cd .. && vagrant up gitlab-server

# 3. Get the Initial Root Password
echo "Retrieving GitLab root password..."
PASS=$(vagrant ssh gitlab-server -c "sudo cat /etc/gitlab/initial_root_password" | grep "Password:" | cut -d' ' -f2)

echo "------------------------------------------------------------"
echo "GitLab is ready at http://192.168.56.120"
echo "User: root"
echo "Password: $PASS"
echo "------------------------------------------------------------"

# 4. Push Part 3 app to GitLab
# (Assumes you have deployment.yaml in your current folder)
echo "Configuring local git and pushing to GitLab..."
git init
git remote add bonus http://root:$PASS@192.168.56.120/root/iot-bonus.git
git add .
git commit -m "bonus: migration from github to gitlab"
git push -u bonus master

# 5. Connect Argo CD to GitLab
echo "Connecting Argo CD to Local GitLab..."
kubectl apply -f confs/application-bonus.yaml