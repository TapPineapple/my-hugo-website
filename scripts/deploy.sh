#!/bin/bash

# Repository and website paths
REPO_PATH="/home/github/git/my-hugo-website"

# Ensure repo directory exists
if [ ! -d "$REPO_PATH" ]; then
    echo "Cloning repository..."
    git clone --recursive https://github.com/TapPineapple/my-hugo-website.git "$REPO_PATH"
else
    echo "Repository exists, updating..."
    cd "$REPO_PATH" || exit
    git submodule update --init --recursive
fi

# Navigate to repo directory
cd "$REPO_PATH" || exit

# Fetch latest changes
git fetch origin main
git reset --hard origin/main

# Build the Hugo site
hugo 

echo "Deployment completed successfully"