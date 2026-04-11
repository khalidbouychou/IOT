#!/bin/bash
set -e

echo "Removing K3d cluster..."
k3d cluster delete khbouy-gitlab

echo "K3d cluster removed successfully"
