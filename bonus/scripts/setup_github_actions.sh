#!/bin/bash
set -e

echo "=== GitHub Actions CI/CD Setup (FREE) ==="
echo ""
echo "GitHub Actions provides:"
echo "  - FREE for public repositories"
echo "  - 2000 free minutes/month for private repos"
echo "  - No setup required - just create workflow files"
echo ""

REPO_ROOT=$(pwd)
WORKFLOWS_DIR="$REPO_ROOT/.github/workflows"

echo "Creating workflows directory..."
mkdir -p "$WORKFLOWS_DIR"

echo "Creating CI/CD pipeline workflows..."

# Create build workflow
cat > "$WORKFLOWS_DIR/build.yml" <<'EOF'
name: Build and Push

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t ghcr.io/${{ github.repository_owner }}/khbouy-iot:v1 .
        docker build -t ghcr.io/${{ github.repository_owner }}/khbouy-iot:v2 .
    
    - name: Login to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Push images
      run: |
        docker push ghcr.io/${{ github.repository_owner }}/khbouy-iot:v1
        docker push ghcr.io/${{ github.repository_owner }}/khbouy-iot:v2
EOF

# Create test workflow
cat > "$WORKFLOWS_DIR/test.yml" <<'EOF'
name: Test Manifests

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Validate YAML manifests
      run: |
        for file in p2/confs/*.yaml p3/confs/*.yaml; do
          echo "Validating $file"
          if [ -f "$file" ]; then
            python3 -c "import yaml; yaml.safe_load(open('$file'))"
          fi
        done
    
    - name: Check deployment syntax
      run: |
        for file in **/deployment.yaml; do
          echo "Checking $file"
          grep -q "apiVersion:" "$file" && echo "✓ Valid"
        done
EOF

echo "Workflows created successfully!"
echo ""
echo "Workflow files:"
echo "  - $WORKFLOWS_DIR/build.yml (Build and push Docker images)"
echo "  - $WORKFLOWS_DIR/test.yml (Validate manifests)"
echo ""
echo "Next steps:"
echo "1. Push these files to GitHub"
echo "2. Go to your repo → Settings → Secrets and variables → Actions"
echo "3. Add any required secrets"
echo "4. Workflows will run automatically on push!"
echo ""
echo "To view workflows:"
echo "  1. Go to your GitHub repo"
echo "  2. Click 'Actions' tab"
echo "  3. Select a workflow to see logs"
