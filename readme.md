# Secure Java Cloud VM Runtime

Production-grade cloud infrastructure project demonstrating secure Linux VM provisioning, application runtime hardening, and automated Java deployment workflows.

## Executive Summary

This project provisions and hardens a Linux cloud VM, deploys a Java application artifact built with Gradle, and configures a secure runtime environment using system-level controls.

It reflects real-world infrastructure engineering practices including:

- SSH hardening and access control
- Least-privilege Linux user management
- Firewall configuration and port isolation
- SystemD service orchestration
- Automated artifact deployment
- Application health verification

This repository represents a secure, production-ready baseline for VM-based application hosting.

## Key Capabilities

- **Infrastructure Provisioning**: Cloud VM provisioning and secure runtime configuration
- **Security Hardening**: SSH key-based auth, disabled root login, minimal firewall rules
- **User Isolation**: Non-root application user with controlled sudo access
- **Automated Deployment**: Scripts for repeatable infrastructure provisioning
- **Service Management**: SystemD for automatic startup and restart on failure
- **Health Monitoring**: Automated health checks and verification

## Engineering Decisions

- Disabled root SSH login to reduce attack surface
- Enforced key-based authentication only
- Created dedicated application user to isolate runtime permissions
- Used SystemD to ensure automatic restart on failure
- Configured UFW to allow only required ports (22, 7071)
- Structured deployment scripts for repeatability and auditability

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
cd secure-java-cloud-vm-runtime
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
secure-java-cloud-vm-runtime/
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
| `LOCAL_JAR` | Path to built JAR file | build/libs/secure-java-cloud-vm-runtime-1.0.0.jar |
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

## Technical Stack

- **Cloud Provider**: DigitalOcean
- **OS**: Ubuntu 22.04 LTS
- **Runtime**: Java 17 JDK
- **Build Tool**: Gradle 8.x
- **Framework**: Spring Boot 3.5.5
- **Service Manager**: SystemD
- **Firewall**: UFW (Uncomplicated Firewall)

## Improvements

- Containerize application with Docker
- Replace manual provisioning with Terraform
- Add CI/CD pipeline with Jenkins or GitHub Actions
- Implement blue-green deployment strategy
- Add centralized logging and monitoring

---

**Infrastructure**: DigitalOcean Cloud VMs  
**Automation**: Bash scripting, SystemD  
**Security**: SSH hardening, UFW firewall, user isolation
