# Quick Start Guide - Cloud Server Foundation

## What You Have Now

Your repository is ready for Module 5 deployment! Here's what's been created:

### 📁 Repository Structure
```
cloud-server-foundation/
├── config/                      # Configuration templates
│   ├── sshd_config.template    # SSH hardening
│   ├── myapp.service.template  # SystemD service
│   └── application.yml.template # Spring Boot config
├── scripts/                     # Deployment automation
│   ├── setup-java.sh           # Install Java 17
│   ├── setup-user.sh           # Create app user
│   ├── setup-app-dirs.sh       # Create directories
│   ├── setup-firewall.sh       # Configure UFW
│   ├── deploy.sh               # Deploy application
│   └── health-check.sh         # Health verification
├── docs/                        # Documentation
│   ├── architecture.md         # System diagrams
│   ├── DEPLOYMENT.md           # Step-by-step guide
│   └── SECURITY.md             # Security best practices
└── README.md                    # Main documentation
```

## 🚀 Deploy in 3 Steps

### 1. Update Configuration

Edit `scripts/deploy.sh`:
```bash
DROPLET_IP="YOUR_DROPLET_IP"  # Your Droplet IP
DROPLET_USER="YOUR_USERNAME"  # Your username
```

### 2. Setup Server (One-time)

SSH to your Droplet and run:
```bash
# Copy scripts to Droplet
scp -r scripts config root@YOUR_DROPLET_IP:/tmp/

# SSH to Droplet
ssh root@YOUR_DROPLET_IP

# Run setup scripts
cd /tmp/scripts
chmod +x *.sh
./setup-java.sh
sudo ./setup-user.sh appuser
sudo ./setup-app-dirs.sh appuser
./setup-firewall.sh

# Setup SSH hardening (AFTER testing appuser login!)
sudo cp /tmp/config/sshd_config.template /etc/ssh/sshd_config
sudo systemctl restart sshd

# Setup SystemD service
sudo cp /tmp/config/myapp.service.template /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
sudo systemctl enable myapp
```

### 3. Deploy Application

From your local machine:
```bash
# Make scripts executable (on Windows, skip this)
chmod +x scripts/*.sh

# Deploy!
./scripts/deploy.sh
```

## ✅ Verify Deployment

```bash
# Check health
./scripts/health-check.sh

# Or visit in browser
http://YOUR_DROPLET_IP:7071
```

## 📚 Full Documentation

- **README.md** - Complete overview and commands
- **docs/DEPLOYMENT.md** - Detailed step-by-step deployment guide
- **docs/SECURITY.md** - Security hardening explained
- **docs/architecture.md** - System architecture diagrams

## 🔧 Common Commands

```bash
# Deploy updates
./scripts/deploy.sh

# Check health
./scripts/health-check.sh

# View logs (on Droplet)
ssh YOUR_USERNAME@YOUR_DROPLET_IP 'sudo journalctl -u myapp -f'

# Restart service (on Droplet)
ssh YOUR_USERNAME@YOUR_DROPLET_IP 'sudo systemctl restart myapp'
```

## 🎯 Module 5 Checklist

- [x] Repository restructured as cloud-server-foundation
- [x] Configuration templates created
- [x] Deployment scripts created
- [x] Architecture diagrams created
- [x] Comprehensive documentation written
- [ ] Server setup completed (you do this)
- [ ] Application deployed (you do this)
- [ ] Health check passing (you verify this)

## 🚦 Next Steps

After completing Module 5:
1. **Module 6**: Setup Nexus artifact repository (separate repo)
2. **Module 7**: Containerize with Docker (separate repo)

## 💡 Tips

- **Always test SSH** with new user before disabling root login
- **Keep backups** of /etc/ssh/sshd_config
- **Monitor logs** after deployment
- **Use health-check.sh** to verify deployments

---

**Ready to deploy?** Start with `docs/DEPLOYMENT.md` for the complete guide!
