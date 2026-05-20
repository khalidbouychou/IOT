#!/bin/bash

# Helper: Auto-detect host IP and update application-bonus.yaml

TRASHBONUS="${TRASHBONUS:-$HOME/Trashbonus}"

# Detect host IP
HOST_IP=$(hostname -I | awk '{print $1}')
GITLAB_PORT=8929

if [ -z "$HOST_IP" ]; then
  echo "❌ Could not detect host IP. Please run: hostname -I"
  exit 1
fi

echo "🔍 Detected host IP: $HOST_IP"
echo "📝 Updating application-bonus.yaml..."

# Update the application manifest with the correct host IP
cat > "bonus/confs/application-bonus.yaml" << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bonus-khbouych
  namespace: argocd
spec:
  project: default
  source:
    # Points to GitLab running on host machine (port 8929)
    repoURL: 'http://$HOST_IP:$GITLAB_PORT/root/iot-bonus.git' 
    targetRevision: HEAD
    path: ./
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
EOF

echo "✅ Updated application-bonus.yaml with host IP: $HOST_IP:$GITLAB_PORT"
echo ""
echo "Next: kubectl apply -f bonus/confs/application-bonus.yaml"
