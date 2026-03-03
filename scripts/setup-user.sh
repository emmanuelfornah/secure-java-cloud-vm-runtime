#!/bin/bash
# Create application user with sudo privileges
# Usage: sudo ./setup-user.sh <username>

set -e  # Exit on error

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: sudo ./setup-user.sh <username>"
    echo "Example: sudo ./setup-user.sh appuser"
    exit 1
fi

USERNAME=$1

echo "========================================="
echo "Creating Application User: $USERNAME"
echo "========================================="

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists. Skipping user creation."
else
    # Create user with home directory
    echo "Creating user $USERNAME..."
    sudo adduser --disabled-password --gecos "" $USERNAME
    echo "User $USERNAME created successfully."
fi

# Add user to sudo group
echo ""
echo "Adding $USERNAME to sudo group..."
sudo usermod -aG sudo $USERNAME

# Create .ssh directory
echo ""
echo "Setting up SSH directory for $USERNAME..."
sudo mkdir -p /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh

# Copy authorized_keys from root (if exists)
if [ -f /root/.ssh/authorized_keys ]; then
    echo "Copying SSH keys from root..."
    sudo cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
    echo "SSH keys copied successfully."
else
    echo "Warning: /root/.ssh/authorized_keys not found."
    echo "You will need to manually add SSH keys to /home/$USERNAME/.ssh/authorized_keys"
fi

# Verify setup
echo ""
echo "========================================="
echo "User Setup Complete!"
echo "========================================="
echo "Username: $USERNAME"
echo "Home Directory: /home/$USERNAME"
echo "Groups: $(groups $USERNAME)"
echo ""
echo "Next steps:"
echo "1. Test SSH login: ssh $USERNAME@<server-ip>"
echo "2. Test sudo access: sudo -l"
echo "3. Consider disabling root SSH login in /etc/ssh/sshd_config"
