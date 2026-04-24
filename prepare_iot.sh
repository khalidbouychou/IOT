#!/bin/bash

# --- 1. SETUP STORAGE DIRECTORIES (The 1TB Goinfre) ---
echo "--- Setting up 1TB storage folders ---"
GOINFRE_PATH="/goinfre/$(whoami)"
mkdir -p "$GOINFRE_PATH/bin"
mkdir -p "$GOINFRE_PATH/vagrant_home"
mkdir -p "$GOINFRE_PATH/vbox_vms"
mkdir -p "$GOINFRE_PATH/docker_storage"

# --- 2. CONFIGURE VAGRANT & VIRTUALBOX ---
# Redirects VirtualBox VMs and Vagrant Boxes to Goinfre
echo "--- Redirecting VirtualBox & Vagrant storage ---"
VBoxManage setproperty machinefolder "$GOINFRE_PATH/vbox_vms"
export VAGRANT_HOME="$GOINFRE_PATH/vagrant_home"

# --- 3. INSTALL BINARIES (Once for all parts) ---
echo "--- Installing kubectl and k3d to Goinfre/bin ---"

# Install kubectl
if [ ! -f "$GOINFRE_PATH/bin/kubectl" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl "$GOINFRE_PATH/bin/"
fi

# Install k3d
if [ ! -f "$GOINFRE_PATH/bin/k3d" ]; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_DIR="$GOINFRE_PATH/bin" USE_SUDO=false bash
fi

# --- 4. PERMANENT PATH CONFIGURATION ---
echo "--- Updating .zshrc ---"
# Add to .zshrc if not already there
grep -qF "$GOINFRE_PATH/bin" ~/.zshrc || echo "export PATH=\$PATH:$GOINFRE_PATH/bin" >> ~/.zshrc
grep -qF "VAGRANT_HOME" ~/.zshrc || echo "export VAGRANT_HOME=$GOINFRE_PATH/vagrant_home" >> ~/.zshrc

# Load changes into current session
export PATH=$PATH:$GOINFRE_PATH/bin
source ~/.zshrc 2>/dev/null

echo "------------------------------------------------------------"
echo "✅ PREPARATION COMPLETE"
echo "Storage: 1TB Goinfre is ready."
echo "Tools: k3d and kubectl are installed in Goinfre/bin."
echo "Context: Run 'source ~/.zshrc' in every new terminal tab."
echo "------------------------------------------------------------"