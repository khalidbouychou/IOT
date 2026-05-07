#!/bin/bash

echo "--- 🛠 Starting Nuclear Cleanup ---"

# 1. DELETE K3D CLUSTERS
if command -v k3d &> /dev/null; then
    echo "🗑 Deleting all k3d clusters..."
    k3d cluster delete --all
fi

# 2. STOP & REMOVE ALL VAGRANT VMs (P1, P2, and Bonus)
echo "🗑 Stopping and deleting all Vagrant VMs..."
# This finds every Vagrant machine managed by your user and destroys it
vagrant global-status | grep virtualbox | cut -d ' ' -f1 | xargs -I {} vagrant destroy -f {}

# 3. WIPE DOCKER (Containers, Images, Volumes, Networks)
echo "🗑 Cleaning Docker system (Removing images and cache)..."
docker system prune -a --volumes -f

# # 4. CLEAN GOINFRE CACHE (VirtualBox & Vagrant data)
echo "🗑 Removing cached VM disks and boxes in Goinfre..."
GOINFRE_PATH="/goinfre/$(whoami)"
rm -rf "$GOINFRE_PATH/vagrant_home"
rm -rf "$GOINFRE_PATH/vbox_vms"
rm -rf "$GOINFRE_PATH/docker_storage"
# Optional: remove GitLab logs/data
rm -rf "$GOINFRE_PATH/gitlab"

# # 5. RE-CREATE CLEAN DIRECTORIES
echo "📂 Re-creating empty storage folders..."
mkdir -p "$GOINFRE_PATH/vagrant_home"
mkdir -p "$GOINFRE_PATH/vbox_vms"

# 6. RESET KUBECONFIG
echo "🗑 Cleaning kubectl config..."
rm -rf ~/.kube/config

echo "------------------------------------------------------------"
echo "✅ CLEANUP COMPLETE"
echo "RAM: All VMs and Containers are stopped."
echo "Disk: All large cache and VM files have been deleted."
echo "Your iMac is now fresh."
echo "------------------------------------------------------------"