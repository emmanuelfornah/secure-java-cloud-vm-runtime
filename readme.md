# Cloud Server Foundation

> DevOps Module 5: Cloud & Infrastructure as a Service Basics

A production-grade infrastructure project demonstrating secure cloud server provisioning, SSH hardening, user management, firewall configuration, and Java application deployment on DigitalOcean.

## 📋 Overview

This repository showcases infrastructure engineering fundamentals by deploying a Java Spring Boot application to a DigitalOcean Droplet with security best practices:

- **Secure SSH Configuration**: Disabled root login, key-based authentication only
- **Least Privilege User Model**: Non-root application user with controlled sudo access
- **Firewall Hardening**: UFW configured with minimal open ports
- **Automated Deployment**: Scripts for repeatable infrastructure setup
- **Service Management**: SystemD for automatic startup and restart on failure

## 🎯 Business Value

- ✅ Reduced attack surface through SSH hardening
- ✅ Enforced least-privilege security model
- ✅ Secure runtime environment for Java applications
- ✅ Repeatable deployment foundation
- ✅ Production-ready cloud baseline

## 🏗️ Architecture

See [Architecture Documentation](docs/architecture.md) for detailed diagrams and component specifications.

**Key Components:**
- DigitalOcean Ubuntu 22.04 Droplet
- UFW Firewall (ports 22, 7071)
- Java 17 Runtime
- Spring Boot Application
- SystemD Service Management

## 🚀 Quick Start

### Prerequisites

- DigitalOcean account with Droplet created
- SSH key pair generated and added to Droplet
- Local machine with:
  - Java 17 JDK
  - Gradle 8.x
  - SSH client
  - Git

### 1. Clone Repository

```bash
git clone <repository-url>
cd cloud-server-foundation
```

### 2. Configure Deployment

Edit `scripts/deploy.sh` and update:

```bash
DROPLET_IP="your-droplet-ip"
DROPLET_USER="your-username"
```

### 3. Initial Server Setup

SSH into your Droplet and run these setup scripts:

```bash
# Install Java 17
./scripts/setup-java.sh

# Create application user
sudo ./scripts/setup-user.sh appuser

# Setup application directories
sudo ./scripts/setup-app-dirs.sh appuser

# Configure firewall
./scripts/setup-firewall.sh
```

### 4. Harden SSH (Important!)

```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply hardened config
sudo cp config/sshd_config.template /etc/ssh/sshd_config

# Restart SSH (test new user login first!)
sudo systemctl restart sshd
```

### 5. Setup SystemD Service

```bash
# Copy service file
sudo cp config/myapp.service.template /etc/systemd/system/myapp.service

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable myapp
```

### 6. Deploy Application

From your local machine:

```bash
./scripts/deploy.sh
```

### 7. Verify Deployment

```bash
# Check health endpoint
./scripts/health-check.sh

# Or manually
curl http://your-droplet-ip:7071/actuator/health
```

## 📁 Repository Structure

```
cloud-server-foundation/
├── config/                      # Configuration templates
│   ├── sshd_config.template    # Hardened SSH configuration
│   ├── myapp.service.template  # SystemD service file
│   └── application.yml.template # Spring Boot configuration
├── scripts/                     # Deployment automation
│   ├── setup-java.sh           # Install Java 17
│   ├── setup-firewall.sh       # Configure UFW
│   ├── setup-user.sh           # Create application user
│   ├── setup-app-dirs.sh       # Create app directories
│   ├── deploy.sh               # Deploy application
│   └── health-check.sh         # Verify application health
├── docs/                        # Documentation
│   ├── architecture.md         # Architecture diagrams
│   ├── DEPLOYMENT.md           # Deployment guide
│   └── SECURITY.md             # Security hardening guide
├── src/                         # Java application source
└── build.gradle                 # Gradle build configuration
```

## 🔧 Configuration

### Environment Variables

Update these in `scripts/deploy.sh`:

| Variable | Description | Default |
|----------|-------------|---------|
| `DROPLET_IP` | DigitalOcean Droplet IP address | YOUR_DROPLET_IP |
| `DROPLET_USER` | Application user name | YOUR_USERNAME |
| `LOCAL_JAR` | Path to built JAR file | build/libs/cloud-server-foundation-1.0.0.jar |
| `REMOTE_DIR` | Application directory on server | /opt/app/current |
| `SERVICE_NAME` | SystemD service name | myapp |

### Application Configuration

Edit `config/application.yml.template`:

- **Server Port**: Default 7071 (must match firewall rules)
- **Management Endpoints**: Health and info exposed
- **Logging**: INFO level, DEBUG for application code

## 📚 Documentation

- [Architecture Documentation](docs/architecture.md) - System diagrams and component details
- [Deployment Guide](docs/DEPLOYMENT.md) - Step-by-step deployment instructions
- [Security Guide](docs/SECURITY.md) - Security hardening best practices

## 🛠️ Common Commands

### On Droplet

```bash
# Check service status
sudo systemctl status myapp

# View logs
sudo journalctl -u myapp -f

# Restart service
sudo systemctl restart myapp

# Check firewall
sudo ufw status verbose
```

### From Local Machine

```bash
# Build application
./gradlew clean build

# Deploy to Droplet
./scripts/deploy.sh

# Check application health
./scripts/health-check.sh
```

## 🔍 Troubleshooting

### Application Won't Start

```bash
# Check Java version
java -version

# Check service logs
sudo journalctl -u myapp -n 50

# Verify JAR exists
ls -la /opt/app/current/app.jar

# Test manual startup
java -jar /opt/app/current/app.jar
```

### Cannot Connect via SSH

```bash
# Check SSH service
sudo systemctl status sshd

# Verify firewall allows SSH
sudo ufw status | grep 22

# Check SSH config
sudo cat /etc/ssh/sshd_config | grep -E "PermitRootLogin|PasswordAuthentication"
```

### Cannot Access Application

```bash
# Check if app is listening
sudo netstat -tlnp | grep 7071

# Check firewall
sudo ufw status | grep 7071

# Test locally on Droplet
curl http://localhost:7071/actuator/health
```

## 🔐 Security Best Practices

- ✅ Root SSH login disabled
- ✅ Password authentication disabled
- ✅ Key-based authentication only
- ✅ Non-root user for application
- ✅ Minimal firewall rules
- ✅ SystemD security settings
- ✅ Regular security updates

## 📖 Learning Objectives

This project demonstrates:

1. Cloud server provisioning (DigitalOcean)
2. SSH security hardening
3. Linux user management and sudo configuration
4. UFW firewall configuration
5. Java runtime environment setup
6. SystemD service management
7. Automated deployment workflows
8. Application health monitoring

## 🚦 Next Steps

After completing this module:

1. **Module 6**: Set up Nexus artifact repository
2. **Module 7**: Containerize with Docker
3. **Module 8**: Implement CI/CD with Jenkins

## 📝 License

This is an educational project for DevOps learning.

## 🤝 Contributing

This is a learning repository. Feel free to fork and adapt for your own learning journey!

---

**Module**: Cloud & Infrastructure as a Service Basics  
**Course**: TechWorld with Nana - DevOps Bootcamp  
**Technologies**: DigitalOcean, Linux, Java 17, Gradle, Spring Boot, SystemD, UFW
