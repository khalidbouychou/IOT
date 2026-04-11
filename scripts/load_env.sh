#!/bin/bash
set -e

# Load environment variables from .env file
ENV_FILE="$(dirname "$0")/../.env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment from $ENV_FILE"
    export $(cat "$ENV_FILE" | grep -v '^#' | grep -v '^$' | xargs)
else
    echo "Warning: .env file not found at $ENV_FILE"
    echo "Copy .env.example to .env and configure as needed"
    exit 1
fi

# Validate required variables
validate_env() {
    local var=$1
    local part=$2
    
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set (required for $part)"
        return 1
    fi
}

# Validate based on which part is being used
if [ "$1" = "p3" ]; then
    validate_env "GITHUB_REPO_URL" "Part 3"
    validate_env "GITHUB_TOKEN" "Part 3"
fi

if [ "$1" = "bonus" ]; then
    validate_env "ARGOCD_GITLAB_TOKEN" "Bonus"
    validate_env "GITLAB_ADMIN_EMAIL" "Bonus"
fi

echo "Environment loaded successfully"
