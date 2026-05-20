#!/bin/bash

# Bonus Cleanup: Remove k3d cluster, Docker containers, and Trashbonus folder

TRASHBONUS="${TRASHBONUS:-$HOME/Trashbonus}"

echo "--- 🛠 Starting Bonus Cleanup ---"

# 1. Delete k3d cluster
if command -v k3d &> /dev/null; then
    echo "🗑 Deleting k3d cluster 'bonus-cluster'..."
    k3d cluster delete bonus-cluster --verbose || echo "⚠️ Cluster already deleted or error occurred"
fi
# Clear the terminal screen
clear
# 2. Stop and remove GitLab container
echo "🗑 Stopping GitLab Docker container..."
docker stop gitlab-bonus 2>/dev/null || true
docker rm gitlab-bonus 2>/dev/null || true

# 3. Clean Docker system (optional)
echo "🗑 Cleaning Docker system..."
docker system prune -a --volumes -f 2>/dev/null || true

# 4. Remove Trashbonus directory
echo "🗑 Removing $TRASHBONUS..."
rm -rf "$TRASHBONUS"

# 5. Clean kubeconfig
echo "🗑 Cleaning kubectl config..."
rm -f ~/.kube/config || true

echo ""
echo "------------------------------------------------------------"
echo "✅ BONUS CLEANUP COMPLETE"
echo "------------------------------------------------------------"
echo "Removed:"
echo "  ✓ k3d cluster (bonus-cluster)"
echo "  ✓ GitLab Docker container"
echo "  ✓ $TRASHBONUS (all cached data)"
echo "  ✓ kubeconfig"
echo ""
echo "Your system is clean. Docker and kubectl remain installed."
echo "------------------------------------------------------------"
