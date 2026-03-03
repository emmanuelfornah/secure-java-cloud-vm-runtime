#!/bin/bash
# Complete Droplet Setup Script for Module 5
# Run this on your DigitalOcean Droplet as the emmanuel user
# Usage: bash complete-droplet-setup.sh

set -e  # Exit on error

echo "========================================="
echo "Cloud Server Foundation - Complete Setup"
echo "========================================="
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Running as user: $CURRENT_USER"
echo ""

# Step 1: Update system
echo "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y
echo "✓ System updated"
echo ""

# Step 2: Install Java 17
echo "Step 2: Installing Java 17..."
if command -v java &> /dev/null; then
    echo "Java is already installed:"
    java -version
else
    sudo apt install -y openjdk-17-jdk
    echo "✓ Java 17 installed"
fi
java -version
echo ""

# Step 3: Create application directories
echo "Step 3: Creating application directories..."
sudo mkdir -p /opt/app/{current,releases,logs,config}
sudo chown -R $CURRENT_USER:$CURRENT_USER /opt/app
sudo chmod 755 /opt/app
sudo chmod 755 /opt/app/current
sudo chmod 755 /opt/app/releases
sudo chmod 755 /opt/app/logs
sudo chmod 755 /opt/app/config
echo "✓ Application directories created"
ls -la /opt/app/
echo ""

# Step 4: Configure firewall
echo "Step 4: Configuring UFW firewall..."
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    sudo apt install -y ufw
fi

# Allow SSH first (prevent lockout)
sudo ufw allow 22/tcp comment 'SSH access'
echo "✓ SSH port 22 allowed"

# Allow application port
sudo ufw allow 7071/tcp comment 'Spring Boot application'
echo "✓ Application port 7071 allowed"

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Enable firewall
echo "Enabling UFW..."
sudo ufw --force enable
echo "✓ Firewall configured"
sudo ufw status verbose
echo ""

# Step 5: Create SystemD service
echo "Step 5: Creating SystemD service..."
sudo tee /etc/systemd/system/myapp.service > /dev/null <<EOF
[Unit]
Description=Java Spring Boot Application - Cloud Server Foundation
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
Group=$CURRENT_USER
WorkingDirectory=/opt/app/current
ExecStart=/usr/bin/java -jar /opt/app/current/app.jar
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp
NoNewPrivileges=true
PrivateTmp=true
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload
echo "✓ SystemD service created"

# Enable service (auto-start on boot)
sudo systemctl enable myapp
echo "✓ Service enabled for auto-start"
echo ""

# Step 6: Summary
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "✓ Java 17 installed"
echo "✓ Application directories created at /opt/app/"
echo "✓ Firewall configured (ports 22, 7071)"
echo "✓ SystemD service created and enabled"
echo ""
echo "Next steps:"
echo "1. From your local machine, build the JAR:"
echo "   gradle clean build"
echo ""
echo "2. Copy JAR to Droplet:"
echo "   scp build/libs/cloud-server-foundation-1.0.0.jar $CURRENT_USER@YOUR_DROPLET_IP:/opt/app/current/app.jar"
echo ""
echo "3. Start the application:"
echo "   sudo systemctl start myapp"
echo ""
echo "4. Check status:"
echo "   sudo systemctl status myapp"
echo ""
echo "5. View logs:"
echo "   sudo journalctl -u myapp -f"
echo ""
echo "6. Access application:"
echo "   http://YOUR_DROPLET_IP:7071"
echo ""
echo "========================================="
