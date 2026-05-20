#!/bin/zsh
set -e

# Bonus Part: Prepare Host Machine (Ubuntu)
# Installs and configures Docker, kubectl, k3d into ~/Trashbonus/
# All cache/data stored in ~/Trashbonus/ to avoid system clutter

STORAGE="$HOME/Trashbonus"
OS=$(uname -s)

echo "========== Bonus Setup: Host Machine (Ubuntu) =========="
echo "Storage location: $STORAGE"

# Detect shell rc file
RC_FILE="$HOME/.zshrc"
if [ ! -f "$RC_FILE" ]; then
  RC_FILE="$HOME/.bashrc"
fi
echo "Using rc file: $RC_FILE"

# Create directories
mkdir -p "$STORAGE/bin" "$STORAGE/docker" "$STORAGE/gitlab" "$STORAGE/k3d-cache"
echo "✅ Created storage folders at: $STORAGE"

# Helper function to safely delete from rc file
sed_delete() {
  local pattern="$1"
  if [ "$OS" = "Darwin" ]; then
    sed -i '' "$pattern" "$RC_FILE" || true
  else
    sed -i "$pattern" "$RC_FILE" || true
  fi
}

# --- Update shell config with environment variables ---
echo "--- Updating $RC_FILE ---"
touch "$RC_FILE"
sed_delete '/export PATH=.*Trashbonus/d'
sed_delete '/export DOCKER_CONFIG=/d'
sed_delete '/export DOCKER_CERT_PATH=/d'
sed_delete '/export K3D_CACHE=/d'
sed_delete '/alias k=/d'

cat >> "$RC_FILE" << 'EOF'

# === Trashbonus (IOT Bonus) Environment ===
export TRASHBONUS="$HOME/Trashbonus"
export PATH="$PATH:$TRASHBONUS/bin"
export DOCKER_CONFIG="$TRASHBONUS/docker"
export DOCKER_CERT_PATH="$TRASHBONUS/docker"
export K3D_CACHE="$TRASHBONUS/k3d-cache"
export KUBECONFIG="$TRASHBONUS/kubeconfig"
alias k='kubectl'
EOF

source "$RC_FILE"
export PATH="$PATH:$STORAGE/bin"
export DOCKER_CONFIG="$STORAGE/docker"
export K3D_CACHE="$STORAGE/k3d-cache"

# --- Install Docker (system-wide, but config in Trashbonus) ---
if ! command -v docker >/dev/null 2>&1; then
  echo "--- Installing Docker ---"
  sudo apt-get update
  sudo apt-get install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo "⚠️  Please log out and log back in for docker group to take effect"
else
  echo "✅ Docker already installed"
fi

# --- Install kubectl ---
if ! command -v kubectl >/dev/null 2>&1 || [ ! -f "$STORAGE/bin/kubectl" ]; then
  echo "--- Installing kubectl v1.24.0 ---"
  rm -f "$STORAGE/bin/kubectl"
  curl -LO "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl "$STORAGE/bin/"
  echo "✅ kubectl installed to $STORAGE/bin/"
else
  echo "✅ kubectl already available"
fi

# --- Install k3d ---
if ! command -v k3d >/dev/null 2>&1 || [ ! -f "$STORAGE/bin/k3d" ]; then
  echo "--- Installing k3d v5.4.6 ---"
  rm -f "$STORAGE/bin/k3d"
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.4.6 K3D_INSTALL_DIR="$STORAGE/bin" USE_SUDO=false bash
  echo "✅ k3d installed to $STORAGE/bin/"
else
  echo "✅ k3d already available"
fi

echo ""
echo "=============================================="
echo "✅ BONUS PREPARATION COMPLETE"
echo "=============================================="
echo "Storage location: $STORAGE"
echo ""
echo "💡 Installed/Configured:"
echo "   ✓ Docker (system-wide, config in $STORAGE/docker)"
echo "   ✓ kubectl v1.24.0 → $STORAGE/bin/"
echo "   ✓ k3d v5.4.6 → $STORAGE/bin/"
echo ""
echo "💡 Next steps:"
echo "   1. Log out and log back in (for docker group)"
echo "   2. Verify: kubectl version && k3d version"
echo "   3. Run: sh bonus/setup_bonus_host.sh"
echo "=============================================="
