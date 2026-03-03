#!/bin/bash
# Configure UFW firewall on Ubuntu
# Usage: ./setup-firewall.sh

set -e  # Exit on error

echo "========================================="
echo "Configuring UFW Firewall"
echo "========================================="

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    echo "UFW not found. Installing..."
    sudo apt update
    sudo apt install -y ufw
fi

echo ""
echo "Configuring firewall rules..."

# IMPORTANT: Allow SSH first to prevent lockout
echo "Allowing SSH (port 22)..."
sudo ufw allow 22/tcp comment 'SSH access'

# Allow application port
echo "Allowing application port (7071)..."
sudo ufw allow 7071/tcp comment 'Spring Boot application'

# Set default policies
echo "Setting default policies (deny incoming, allow outgoing)..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Enable UFW
echo ""
echo "Enabling UFW firewall..."
sudo ufw --force enable

# Show status
echo ""
echo "========================================="
echo "Firewall Configuration Complete!"
echo "========================================="
sudo ufw status verbose

echo ""
echo "Active firewall rules:"
sudo ufw status numbered
