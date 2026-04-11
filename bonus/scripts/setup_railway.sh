#!/bin/bash
set -e

echo "=== Railway.app Deployment Setup ==="
echo ""
echo "Railway offers free tier: $5 credit/month + $5 bonus for students"
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
fi

echo ""
echo "Step 1: Login to Railway"
echo "Visit: https://railway.app and sign up (FREE for students)"
railway login

echo ""
echo "Step 2: Create a new project"
railway init

echo ""
echo "Step 3: Select or create environment"
echo "Following Railway CLI prompts..."

echo ""
echo "Step 4: Add services"
railway add -s postgresql
railway add -s redis

echo ""
echo "Step 5: Set environment variables"
railway variables set GITHUB_TOKEN="$GITHUB_TOKEN"
railway variables set APP_VERSION="v1"

echo ""
echo "Step 6: Deploy application"
railway up

echo ""
echo "Deployment complete!"
echo "View logs: railway logs"
echo "Open dashboard: railway open"
