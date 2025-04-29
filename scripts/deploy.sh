#!/bin/bash

# Repository and website paths
REPO_PATH="~/git/my-hugo-website"
WEBSITE_PATH="/var/www/public"

# Ensure repo directory exists
if [ ! -d "$REPO_PATH" ]; then
    git clone https://github.com/TapPineapple/my-hugo-website.git "$REPO_PATH"
fi

# Navigate to repo directory
cd "$REPO_PATH" || exit

# Fetch latest changes
git fetch origin main
git reset --hard origin/main

hugo 

# Copy built files to web root
sudo cp -r public/* "$WEBSITE_PATH"

echo "Deployment completed successfully"