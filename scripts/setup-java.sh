#!/bin/bash
# Install Java 17 on Ubuntu
# Usage: ./setup-java.sh

set -e  # Exit on error

echo "========================================="
echo "Installing Java 17 JDK"
echo "========================================="

# Update package list
echo "Updating package list..."
sudo apt update

# Install OpenJDK 17
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk

# Verify installation
echo ""
echo "Verifying Java installation..."
java -version

# Set JAVA_HOME
echo ""
echo "Setting JAVA_HOME environment variable..."
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME_PATH" | sudo tee -a /etc/environment
echo "export PATH=\$PATH:\$JAVA_HOME/bin" | sudo tee -a /etc/environment

echo ""
echo "========================================="
echo "Java 17 installation complete!"
echo "========================================="
echo "JAVA_HOME: $JAVA_HOME_PATH"
echo ""
echo "Note: You may need to logout and login again for JAVA_HOME to take effect"
