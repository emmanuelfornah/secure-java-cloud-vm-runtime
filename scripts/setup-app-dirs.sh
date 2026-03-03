#!/bin/bash
# Create application directory structure
# Usage: sudo ./setup-app-dirs.sh <username>

set -e  # Exit on error

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: sudo ./setup-app-dirs.sh <username>"
    echo "Example: sudo ./setup-app-dirs.sh appuser"
    exit 1
fi

USERNAME=$1

echo "========================================="
echo "Creating Application Directory Structure"
echo "========================================="

# Create main application directory
echo "Creating /opt/app directory structure..."
sudo mkdir -p /opt/app/{current,releases,logs,config}

# Set ownership to application user
echo "Setting ownership to $USERNAME..."
sudo chown -R $USERNAME:$USERNAME /opt/app

# Set permissions
echo "Setting permissions..."
sudo chmod 755 /opt/app
sudo chmod 755 /opt/app/current
sudo chmod 755 /opt/app/releases
sudo chmod 755 /opt/app/logs
sudo chmod 755 /opt/app/config

# Verify setup
echo ""
echo "========================================="
echo "Directory Setup Complete!"
echo "========================================="
echo "Directory structure:"
ls -la /opt/app/

echo ""
echo "Ownership and permissions:"
ls -ld /opt/app /opt/app/*

echo ""
echo "Application directories ready for deployment!"
