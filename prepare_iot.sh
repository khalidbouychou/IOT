#!/bin/bash

# 1. Clean the old broken lines from your config
sed -i '' '/export PATH=.*goinfre/d' ~/.zshrc
sed -i '' '/export VAGRANT_HOME=/d' ~/.zshrc

# 2. Add the correct, quoted paths
echo "export PATH=\"\$PATH:/goinfre/$(whoami)/bin\"" >> ~/.zshrc
echo "export VAGRANT_HOME=\"/goinfre/$(whoami)/vagrant_home\"" >> ~/.zshrc
echo "alias k='kubectl'" >> ~/.zshrc

# 3. Apply changes
source ~/.zshrc

# --- 1. SETUP STORAGE DIRECTORIES (The 1TB Goinfre) ---
echo "--- Setting up 1TB storage folders ---"
GOINFRE="/goinfre/$(whoami)"
mkdir -p "$GOINFRE/bin"
mkdir -p "$GOINFRE/vagrant_home"
mkdir -p "$GOINFRE/vbox_vms"

# --- 2. CONFIGURE VAGRANT & VIRTUALBOX ---
# Redirects storage to prevent 5GB home session from filling up
echo "--- Redirecting VirtualBox & Vagrant storage ---"
VBoxManage setproperty machinefolder "$GOINFRE/vbox_vms" 2>/dev/null || echo "VBox folder already set"
export VAGRANT_HOME="$GOINFRE/vagrant_home"

# --- 3. INSTALL CATALINA-COMPATIBLE BINARIES (Intel amd64) ---
echo "--- Installing kubectl and k3d to Goinfre/bin ---"

# FIX: Install kubectl v1.24.0 (Later versions crash on macOS 10.15)
rm -f "$GOINFRE/bin/kubectl"
echo "📥 Downloading kubectl v1.24.0 (Catalina-Compatible)..."
curl -LO "https://dl.k8s.io/release/v1.24.0/bin/darwin/amd64/kubectl"
chmod +x kubectl
mv kubectl "$GOINFRE/bin/"

# Install k3d (Handles Intel Mac automatically)
rm -f "$GOINFRE/bin/k3d"
echo "📥 Downloading k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.4.6 K3D_INSTALL_DIR="$GOINFRE/bin" USE_SUDO=false bash

# --- 4. CLEAN AND UPDATE SHELL CONFIG (.zshrc) ---
echo "--- Cleaning and updating .zshrc ---"

# Use quotes to avoid "not valid in this context" errors
# We use a temporary file to rebuild a clean PATH logic
touch ~/.zshrc
sed -i '' '/export PATH=.*goinfre/d' ~/.zshrc
sed -i '' '/export VAGRANT_HOME=/d' ~/.zshrc

echo "export VAGRANT_HOME=\"$GOINFRE/vagrant_home\"" >> ~/.zshrc
echo "export PATH=\"\$PATH:$GOINFRE/bin\"" >> ~/.zshrc
echo "alias k='kubectl'" >> ~/.zshrc

# Load changes into current session
export PATH="$PATH:$GOINFRE/bin"
export VAGRANT_HOME="$GOINFRE/vagrant_home"
source ~/.zshrc
echo "------------------------------------------------------------"
echo "✅ PREPARATION COMPLETE"
echo "Binary Fix: Kubectl v1.24.0 installed (Intel/Catalina Fix)."
echo "Storage: VMs and Boxes redirected to 1TB Goinfre."
echo "Action: Run 'source ~/.zshrc' now."
echo "------------------------------------------------------------"