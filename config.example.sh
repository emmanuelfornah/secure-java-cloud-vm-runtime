#!/bin/bash
# Configuration Template
# Copy this file to config.local.sh and fill in your values
# config.local.sh is gitignored for security

# DigitalOcean Droplet Configuration
export DROPLET_IP="YOUR_DROPLET_IP"          # e.g., "164.90.218.238"
export DROPLET_USER="YOUR_USERNAME"          # e.g., "appuser" or "emmanuel"

# Application Configuration
export APP_PORT="7071"
export SERVICE_NAME="myapp"

# Paths
export LOCAL_JAR="build/libs/cloud-server-foundation-1.0.0.jar"
export REMOTE_DIR="/opt/app/current"

# Usage:
# 1. Copy this file: cp config.example.sh config.local.sh
# 2. Edit config.local.sh with your values
# 3. Source it before deploying: source config.local.sh
# 4. Run deployment: ./scripts/deploy.sh
