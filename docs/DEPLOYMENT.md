# Deployment Guide

Complete step-by-step guide for deploying the Java Spring Boot application to DigitalOcean.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Server Setup](#initial-server-setup)
3. [Security Hardening](#security-hardening)
4. [Application Deployment](#application-deployment)
5. [Verification](#verification)
6. [Ongoing Deployments](#ongoing-deployments)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Local Machine Requirements

- Java 17 JDK installed
- Gradle 8.x installed
- SSH client (OpenSSH)
- Git
- curl (for health checks)

### DigitalOcean Requirements

- Active DigitalOcean account
- Droplet created (Ubuntu 22.04 LTS)
- SSH key pair generated and added to Droplet
- Droplet IP address noted

### Generate SSH Key (if needed)

```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Or RSA key
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub
```

## Initial Server Setup

### Step 1: Connect to Droplet as Root

```bash
ssh root@your-droplet-ip
```

### Step 2: Update System Packages

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 3: Install Java 17

```bash
# Transfer setup script
scp scripts/setup-java.sh root@your-droplet-ip:/tmp/

# SSH to droplet
ssh root@your-droplet-ip

# Run installation
cd /tmp
chmod +x setup-java.sh
./setup-java.sh

# Verify installation
java -version
# Expected: openjdk version "17.x.x"
```

### Step 4: Create Application User

```bash
# Transfer setup script
scp scripts/setup-user.sh root@your-droplet-ip:/tmp/

# SSH to droplet
ssh root@your-droplet-ip

# Run user creation (replace 'appuser' with your preferred username)
cd /tmp
chmod +x setup-user.sh
sudo ./setup-user.sh appuser

# Verify user creation
id appuser
groups appuser
```

### Step 5: Test New User SSH Access

**IMPORTANT**: Test this before disabling root login!

```bash
# From local machine
ssh appuser@your-droplet-ip

# Test sudo access
sudo whoami
# Should output: root
```

If this works, you can proceed. If not, troubleshoot before continuing.

### Step 6: Setup Application Directories

```bash
# Transfer setup script
scp scripts/setup-app-dirs.sh appuser@your-droplet-ip:/tmp/

# SSH as application user
ssh appuser@your-droplet-ip

# Run directory setup
cd /tmp
chmod +x setup-app-dirs.sh
sudo ./setup-app-dirs.sh appuser

# Verify directories
ls -la /opt/app/
```

### Step 7: Configure Firewall

```bash
# Transfer firewall script
scp scripts/setup-firewall.sh appuser@your-droplet-ip:/tmp/

# SSH to droplet
ssh appuser@your-droplet-ip

# Run firewall setup
cd /tmp
chmod +x setup-firewall.sh
./setup-firewall.sh

# Verify firewall rules
sudo ufw status verbose
```

Expected output:
```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
7071/tcp                   ALLOW       Anywhere
```

## Security Hardening

### Step 8: Harden SSH Configuration

**WARNING**: Only do this after verifying the application user can SSH successfully!

```bash
# Transfer SSH config template
scp config/sshd_config.template appuser@your-droplet-ip:/tmp/

# SSH to droplet
ssh appuser@your-droplet-ip

# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply hardened config
sudo cp /tmp/sshd_config.template /etc/ssh/sshd_config

# Test SSH config syntax
sudo sshd -t

# If no errors, restart SSH
sudo systemctl restart sshd
```

**Test immediately**: Open a new terminal and try to SSH as root:
```bash
ssh root@your-droplet-ip
# Should be denied
```

Try to SSH with password (should fail):
```bash
ssh -o PreferredAuthentications=password appuser@your-droplet-ip
# Should be denied
```

### Step 9: Setup SystemD Service

```bash
# Transfer service template
scp config/myapp.service.template appuser@your-droplet-ip:/tmp/

# SSH to droplet
ssh appuser@your-droplet-ip

# Copy service file
sudo cp /tmp/myapp.service.template /etc/systemd/system/myapp.service

# Reload systemd
sudo systemctl daemon-reload

# Enable service (auto-start on boot)
sudo systemctl enable myapp

# Verify service is enabled
sudo systemctl is-enabled myapp
# Should output: enabled
```

## Application Deployment

### Step 10: Build Application Locally

```bash
# From local machine, in project root
./gradlew clean build

# Verify JAR was created
ls -la build/libs/
# Should see: cloud-server-foundation-1.0.0.jar
```

### Step 11: Configure Deployment Script

Edit `scripts/deploy.sh` and update:

```bash
DROPLET_IP="your-droplet-ip"
DROPLET_USER="appuser"
```

### Step 12: Deploy Application

```bash
# Make deploy script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

The script will:
1. Build the application
2. Transfer JAR to Droplet
3. Restart the service
4. Verify health endpoint

## Verification

### Step 13: Verify Service Status

```bash
# SSH to droplet
ssh appuser@your-droplet-ip

# Check service status
sudo systemctl status myapp

# Should show: Active: active (running)
```

### Step 14: Check Application Logs

```bash
# View recent logs
sudo journalctl -u myapp -n 50

# Follow logs in real-time
sudo journalctl -u myapp -f
```

### Step 15: Test Health Endpoint

```bash
# From local machine
./scripts/health-check.sh

# Or manually
curl http://your-droplet-ip:7071/actuator/health

# Expected response:
# {"status":"UP"}
```

### Step 16: Test Application in Browser

Open browser and navigate to:
```
http://your-droplet-ip:7071
```

You should see the application homepage.

## Ongoing Deployments

For subsequent deployments after initial setup:

```bash
# 1. Make code changes
# 2. Run deployment script
./scripts/deploy.sh

# That's it! The script handles:
# - Building
# - Transferring
# - Restarting
# - Health checking
```

### Manual Deployment Steps

If you prefer manual control:

```bash
# 1. Build locally
./gradlew clean build

# 2. Transfer JAR
scp build/libs/cloud-server-foundation-1.0.0.jar appuser@your-droplet-ip:/opt/app/current/app.jar

# 3. SSH to droplet
ssh appuser@your-droplet-ip

# 4. Restart service
sudo systemctl restart myapp

# 5. Check status
sudo systemctl status myapp

# 6. Verify health
curl http://localhost:7071/actuator/health
```

## Troubleshooting

### Service Won't Start

```bash
# Check service status
sudo systemctl status myapp

# View detailed logs
sudo journalctl -u myapp -n 100 --no-pager

# Common issues:
# - Java not installed: java -version
# - JAR file missing: ls -la /opt/app/current/app.jar
# - Wrong permissions: sudo chown appuser:appuser /opt/app/current/app.jar
# - Port already in use: sudo netstat -tlnp | grep 7071
```

### Cannot Connect via SSH

```bash
# From DigitalOcean console (not SSH):

# Check SSH service
sudo systemctl status sshd

# Check firewall
sudo ufw status

# Verify SSH config
sudo cat /etc/ssh/sshd_config | grep -E "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication"

# Restore backup if needed
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Application Not Accessible from Browser

```bash
# SSH to droplet
ssh appuser@your-droplet-ip

# Check if app is running
sudo systemctl status myapp

# Check if app is listening on port
sudo netstat -tlnp | grep 7071

# Check firewall
sudo ufw status | grep 7071

# Test locally first
curl http://localhost:7071/actuator/health

# If local works but external doesn't, check DigitalOcean firewall in dashboard
```

### Deployment Script Fails

```bash
# Check each step manually:

# 1. Can you build?
./gradlew clean build

# 2. Can you connect via SSH?
ssh appuser@your-droplet-ip

# 3. Can you transfer files?
scp build/libs/*.jar appuser@your-droplet-ip:/tmp/test.jar

# 4. Check disk space on droplet
ssh appuser@your-droplet-ip "df -h"

# 5. Check service status
ssh appuser@your-droplet-ip "sudo systemctl status myapp"
```

### Service Keeps Restarting

```bash
# View logs to see crash reason
sudo journalctl -u myapp -n 200

# Common causes:
# - Application crashes on startup
# - Port already in use
# - Missing dependencies
# - Configuration errors

# Test manual startup
sudo systemctl stop myapp
sudo -u appuser java -jar /opt/app/current/app.jar
# Watch for errors
```

## Manual Verification Checklist

After deployment, verify:

- [ ] SSH connection works with key-based auth
- [ ] Root login via SSH is blocked
- [ ] Password authentication is disabled
- [ ] Non-root user can sudo
- [ ] Java 17 is installed and active
- [ ] Application starts and binds to port 7071
- [ ] Firewall allows only ports 22 and 7071
- [ ] Application accessible from external browser
- [ ] Health check endpoint returns 200
- [ ] SystemD service starts on boot
- [ ] Service restarts automatically on failure
- [ ] Logs accessible via journalctl

## Rollback Procedure

If deployment fails:

```bash
# 1. SSH to droplet
ssh appuser@your-droplet-ip

# 2. Copy previous version from releases
sudo cp /opt/app/releases/app-previous.jar /opt/app/current/app.jar

# 3. Restart service
sudo systemctl restart myapp

# 4. Verify
curl http://localhost:7071/actuator/health
```

## Best Practices

1. **Always test SSH access** before disabling root login
2. **Keep backups** of configuration files
3. **Monitor logs** after deployment
4. **Test health endpoint** before considering deployment complete
5. **Document changes** to server configuration
6. **Keep previous JAR versions** in /opt/app/releases/
7. **Use version tags** in JAR filenames
8. **Test in staging** before production (if available)

## Next Steps

After successful deployment:

1. Set up monitoring and alerting
2. Configure log rotation
3. Implement automated backups
4. Set up SSL/TLS with reverse proxy (nginx)
5. Configure custom domain name
6. Implement CI/CD pipeline

---

**Need Help?**

- Check logs: `sudo journalctl -u myapp -f`
- Check service: `sudo systemctl status myapp`
- Check firewall: `sudo ufw status verbose`
- Test health: `curl http://localhost:7071/actuator/health`
