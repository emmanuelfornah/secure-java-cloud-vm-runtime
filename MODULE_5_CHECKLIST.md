# Module 5 Checklist - Cloud & IaaS Basics

## Video Overview
- [ ] ★ Introduction to Cloud & Infrastructure as a Service
- [ ] ★ Setup server on DigitalOcean
- [ ] ★ Deploy App on Droplet
- [ ] ★ Create a Linux User

---

## Introduction to Cloud & IaaS
- [ ] Watched video

---

## Setup a Server on DigitalOcean
- [ ] Watched video
- [ ] Demo executed
- [ ] Created a DigitalOcean account (Free Tier)
- [ ] Created a Droplet (Ubuntu 22.04 LTS recommended)
- [ ] Configured Firewall rule to open port 22 for your IP address
- [ ] Connected to Droplet via SSH
- [ ] Installed Java 17 on Droplet

**Commands:**
```bash
# SSH to Droplet
ssh YOUR_USERNAME@YOUR_DROPLET_IP

# Install Java 17
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

---

## Deploy Application on Droplet
- [ ] Watched video
- [ ] Demo executed
- [ ] Built JAR File with gradle locally
- [ ] Copied JAR to remote Server (Droplet)
- [ ] Created application directories on Droplet
- [ ] Created SystemD service for application
- [ ] Run App on Droplet
- [ ] Configured Firewall Rule to open port 7071 to access App via browser
- [ ] Verified application is accessible in browser

**Commands:**
```bash
# Local: Build JAR
gradle clean build

# Local: Copy to Droplet
scp build/libs/cloud-server-foundation-1.0.0.jar YOUR_USERNAME@YOUR_DROPLET_IP:/opt/app/current/app.jar

# Droplet: Create directories
sudo mkdir -p /opt/app/current
sudo chown -R YOUR_USERNAME:YOUR_USERNAME /opt/app

# Droplet: Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 7071/tcp
sudo ufw --force enable
sudo ufw status

# Droplet: Create SystemD service
sudo nano /etc/systemd/system/myapp.service
# (paste service configuration)

# Droplet: Start application
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
sudo systemctl status myapp

# Verify in browser
http://YOUR_DROPLET_IP:7071
```

---

## Create a Linux User
- [ ] Watched video
- [ ] Demo executed
- [ ] Added User (non-root application user)
- [ ] Added new User to sudo group
- [ ] Created .ssh folder with ssh key for new User
- [ ] Verified new user can SSH to Droplet
- [ ] Verified new user has sudo access

**Commands:**
```bash
# Create user
sudo adduser YOUR_USERNAME

# Add to sudo group
sudo usermod -aG sudo YOUR_USERNAME

# Setup SSH for new user
sudo mkdir -p /home/YOUR_USERNAME/.ssh
sudo cp /root/.ssh/authorized_keys /home/YOUR_USERNAME/.ssh/
sudo chown -R YOUR_USERNAME:YOUR_USERNAME /home/YOUR_USERNAME/.ssh
sudo chmod 700 /home/YOUR_USERNAME/.ssh
sudo chmod 600 /home/YOUR_USERNAME/.ssh/authorized_keys

# Test SSH as new user
ssh YOUR_USERNAME@YOUR_DROPLET_IP

# Test sudo access
sudo whoami
# Should output: root
```

---

## Security Hardening (Bonus)
- [ ] Disabled root SSH login
- [ ] Disabled password authentication
- [ ] Configured SSH to use key-based auth only
- [ ] Verified firewall rules are minimal (only ports 22, 7071)

**Commands:**
```bash
# Backup SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Set these values:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd

# Verify firewall
sudo ufw status verbose
```

---

## Final Verification
- [ ] Application is running: `sudo systemctl status myapp`
- [ ] Application is accessible: `http://YOUR_DROPLET_IP:7071`
- [ ] Health endpoint works: `http://YOUR_DROPLET_IP:7071/actuator/health`
- [ ] Logs are accessible: `sudo journalctl -u myapp -f`
- [ ] Service auto-starts on boot: `sudo systemctl is-enabled myapp`
- [ ] Firewall is active: `sudo ufw status`
- [ ] Only necessary ports are open (22, 7071)

---

## Repository Checklist
- [ ] All scripts created and documented
- [ ] Configuration templates created
- [ ] Documentation complete (README, DEPLOYMENT, SECURITY)
- [ ] Architecture diagrams created
- [ ] Business case documented
- [ ] All sensitive data removed (no IPs, usernames, passwords)
- [ ] .gitignore configured properly
- [ ] Ready to commit to Git

---

## Check Your Progress
**Module 5 Complete!** ✅

**Next Steps:**
- Commit your repository to Git
- Move to Module 6: Artifact Repository Manager with Nexus (separate repo)
- Continue building your DevOps portfolio

---

**Congratulations!** You've successfully deployed a Java application to the cloud with production-grade security practices.
