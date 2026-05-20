#!/bin/bash

echo "🧹 Starting clean-up..."

# 1. Stop and remove GitLab (if running via Docker)
if [ "$(docker ps -q -f name=gitlab)" ]; then
    echo "🦊 Stopping GitLab..."
    docker stop gitlab > /dev/null
    docker rm gitlab > /dev/null
    # Remove GitLab data (Optional: remove this if you want to keep your GitLab repos)
    # sudo rm -rf /srv/gitlab
fi

# 2. Delete all K3d clusters
echo "☸️ Deleting all k3d clusters..."
k3d cluster delete --all || true

# 3. Clean up Docker (Containers, Networks, Volumes)
echo "🐳 Pruning Docker (dangling resources)..."
docker container prune -f
docker volume prune -f
docker network prune -f

# 4. Remove leftover Kubeconfig entries
# This clears out the cluster info from your local machine
rm -f ~/.kube/config

# 5. Stop any rogue process listening on your ports (8080/8081/9999)
echo "🔌 Releasing ports..."
for port in 8080 8081 9999; do
    PID=$(lsof -t -i:$port)
    if [ ! -z "$PID" ]; then
        echo "Killing process $PID using port $port"
        kill -9 $PID
    fi
done

echo "✅ Clean-up complete! Your environment is now factory-fresh."