# Security Hardening Guide

This guide explains the security measures implemented in the Cloud Server Foundation and provides best practices for maintaining a secure cloud infrastructure.

## Table of Contents

1. [Security Overview](#security-overview)
2. [SSH Hardening](#ssh-hardening)
3. [User Management](#user-management)
4. [Firewall Configuration](#firewall-configuration)
5. [Application Security](#application-security)
6. [System Security](#system-security)
7. [Monitoring and Auditing](#monitoring-and-auditing)
8. [Security Checklist](#security-checklist)

## Security Overview

### Defense in Depth

This project implements multiple layers of security:

1. **Network Layer**: Firewall with minimal open ports
2. **Access Layer**: SSH hardening and key-based authentication
3. **User Layer**: Least privilege principle with non-root users
4. **Application Layer**: SystemD security settings and resource limits
5. **Monitoring Layer**: Logging and health checks

### Security Principles

- **Least Privilege**: Users and processes have minimum required permissions
- **Defense in Depth**: Multiple security layers
- **Fail Secure**: Default deny policies
- **Audit Trail**: Comprehensive logging
- **Separation of Duties**: Root vs application user

## SSH Hardening

### Why SSH Hardening Matters

SSH is the primary access point to your server. Weak SSH configuration is a common attack vector:

- **Brute force attacks**: Automated password guessing
- **Root compromise**: Direct root access if compromised
- **Man-in-the-middle**: Weak encryption algorithms

### Implemented SSH Security Measures

#### 1. Disable Root Login

**Configuration**: `PermitRootLogin no`

**Rationale**:
- Prevents direct root access via SSH
- Forces use of non-root user with sudo
- Adds accountability (know who ran sudo commands)
- Limits blast radius of compromised credentials

**Verification**:
```bash
# Should fail
ssh root@your-droplet-ip

# Check config
sudo grep "PermitRootLogin" /etc/ssh/sshd_config
```

#### 2. Disable Password Authentication

**Configuration**: `PasswordAuthentication no`

**Rationale**:
- Prevents brute force password attacks
- Eliminates weak password vulnerabilities
- Forces use of SSH keys (much stronger)

**Verification**:
```bash
# Should fail
ssh -o PreferredAuthentications=password appuser@your-droplet-ip

# Check config
sudo grep "PasswordAuthentication" /etc/ssh/sshd_config
```

#### 3. Enable Public Key Authentication

**Configuration**: `PubkeyAuthentication yes`

**Rationale**:
- SSH keys are cryptographically strong (2048-4096 bit)
- Cannot be brute forced in reasonable time
- Can be easily revoked if compromised

**Best Practices**:
```bash
# Use ED25519 (modern, secure, fast)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Or RSA 4096-bit
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Protect private key
chmod 600 ~/.ssh/id_ed25519
```

#### 4. Disable Challenge-Response Authentication

**Configuration**: `ChallengeResponseAuthentication no`

**Rationale**:
- Prevents keyboard-interactive authentication
- Closes potential bypass of password authentication

#### 5. Disable X11 Forwarding

**Configuration**: `X11Forwarding no`

**Rationale**:
- Not needed for server environments
- Reduces attack surface
- Prevents X11 vulnerabilities

### Additional SSH Hardening (Optional)

Consider these additional measures for production:

```bash
# Limit SSH to specific users
AllowUsers appuser

# Change default SSH port (security through obscurity)
Port 2222

# Limit authentication attempts
MaxAuthTries 3

# Set login grace time
LoginGraceTime 30

# Disable empty passwords
PermitEmptyPasswords no

# Use strong ciphers only
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com

# Use strong MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

## User Management

### Principle of Least Privilege

**Never run applications as root.**

### Application User Setup

#### Why Non-Root User?

- **Containment**: Limits damage if application is compromised
- **Accountability**: Clear audit trail of who did what
- **Best Practice**: Industry standard for production systems

#### User Configuration

```bash
# Create user
sudo adduser appuser

# Add to sudo group (for administrative tasks)
sudo usermod -aG sudo appuser

# Setup SSH keys
sudo mkdir -p /home/appuser/.ssh
sudo cp /root/.ssh/authorized_keys /home/appuser/.ssh/
sudo chown -R appuser:appuser /home/appuser/.ssh
sudo chmod 700 /home/appuser/.ssh
sudo chmod 600 /home/appuser/.ssh/authorized_keys
```

#### Sudo Configuration

**Current**: Full sudo access with password

**Production Recommendation**: Limit sudo to specific commands

```bash
# Edit sudoers file
sudo visudo

# Add specific permissions
appuser ALL=(ALL) NOPASSWD: /bin/systemctl restart myapp
appuser ALL=(ALL) NOPASSWD: /bin/systemctl status myapp
appuser ALL=(ALL) NOPASSWD: /bin/journalctl -u myapp
```

### File Permissions

```bash
# Application directory
sudo chown -R appuser:appuser /opt/app
sudo chmod 755 /opt/app

# JAR file
sudo chmod 644 /opt/app/current/app.jar

# Scripts (executable)
chmod 755 scripts/*.sh

# Configuration files (read-only)
chmod 644 config/*
```

## Firewall Configuration

### UFW (Uncomplicated Firewall)

#### Default Deny Policy

**Configuration**:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

**Rationale**:
- Blocks all incoming traffic by default
- Only explicitly allowed services are accessible
- Reduces attack surface significantly

#### Minimal Open Ports

**Port 22 (SSH)**:
```bash
sudo ufw allow 22/tcp comment 'SSH access'
```

**Port 7071 (Application)**:
```bash
sudo ufw allow 7071/tcp comment 'Spring Boot application'
```

#### Firewall Best Practices

1. **Always allow SSH first** (prevent lockout)
2. **Use specific ports** (not port ranges)
3. **Add comments** to rules for documentation
4. **Review rules regularly**
5. **Log denied connections** for monitoring

```bash
# Enable logging
sudo ufw logging on

# View logs
sudo tail -f /var/log/ufw.log
```

#### Advanced Firewall Rules (Optional)

```bash
# Limit SSH connections (rate limiting)
sudo ufw limit 22/tcp

# Allow from specific IP only
sudo ufw allow from 203.0.113.0/24 to any port 22

# Allow specific subnet
sudo ufw allow from 10.0.0.0/8 to any port 7071
```

### DigitalOcean Cloud Firewall

Consider using DigitalOcean's cloud firewall for additional protection:

- **Inbound Rules**: Same as UFW (22, 7071)
- **Outbound Rules**: Allow all (or restrict as needed)
- **Benefits**: Protection before traffic reaches Droplet

## Application Security

### SystemD Security Settings

#### NoNewPrivileges

**Configuration**: `NoNewPrivileges=true`

**Rationale**:
- Prevents privilege escalation
- Process cannot gain more privileges than it started with

#### PrivateTmp

**Configuration**: `PrivateTmp=true`

**Rationale**:
- Isolates /tmp directory
- Prevents temp file attacks
- Other processes cannot access application's temp files

#### Resource Limits

**Configuration**: `LimitNOFILE=65536`

**Rationale**:
- Prevents resource exhaustion
- Limits file descriptor usage
- Protects against DoS attacks

### Spring Boot Security

#### Actuator Endpoints

**Configuration**:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info
```

**Rationale**:
- Only expose necessary endpoints
- Health and info are safe for public access
- Sensitive endpoints (env, beans) are not exposed

**Production Recommendation**:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health
  endpoint:
    health:
      show-details: when-authorized
```

#### Application Port

**Configuration**: `server.port: 7071`

**Rationale**:
- Non-privileged port (>1024)
- Can run as non-root user
- Matches firewall rules

## System Security

### Keep System Updated

```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade -y

# Reboot if kernel updated
sudo reboot
```

**Recommendation**: Enable automatic security updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Disable Unnecessary Services

```bash
# List running services
systemctl list-units --type=service --state=running

# Disable unnecessary services
sudo systemctl disable <service-name>
sudo systemctl stop <service-name>
```

### Fail2Ban (Optional)

Protect against brute force attacks:

```bash
# Install fail2ban
sudo apt install fail2ban

# Configure for SSH
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local

# Enable and start
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Monitoring and Auditing

### Log Monitoring

#### SystemD Logs

```bash
# View application logs
sudo journalctl -u myapp -f

# View SSH logs
sudo journalctl -u sshd -f

# View all logs since boot
sudo journalctl -b
```

#### UFW Logs

```bash
# Enable UFW logging
sudo ufw logging on

# View firewall logs
sudo tail -f /var/log/ufw.log

# View denied connections
sudo grep "BLOCK" /var/log/ufw.log
```

#### Auth Logs

```bash
# View authentication attempts
sudo tail -f /var/log/auth.log

# View failed SSH attempts
sudo grep "Failed password" /var/log/auth.log

# View successful logins
sudo grep "Accepted publickey" /var/log/auth.log
```

### Security Auditing

#### Check for Failed Login Attempts

```bash
# Failed SSH attempts
sudo grep "Failed password" /var/log/auth.log | wc -l

# Failed sudo attempts
sudo grep "sudo.*FAILED" /var/log/auth.log
```

#### Check Open Ports

```bash
# List listening ports
sudo netstat -tlnp

# Or with ss
sudo ss -tlnp
```

#### Check Running Processes

```bash
# List all processes
ps aux

# Check for suspicious processes
ps aux | grep -v "appuser\|root"
```

## Security Checklist

### Initial Setup

- [ ] SSH key-based authentication configured
- [ ] Root SSH login disabled
- [ ] Password authentication disabled
- [ ] Non-root application user created
- [ ] User has sudo access (limited if possible)
- [ ] UFW firewall enabled
- [ ] Only necessary ports open (22, 7071)
- [ ] SystemD service configured with security settings
- [ ] Application runs as non-root user

### Ongoing Maintenance

- [ ] System packages updated regularly
- [ ] Security patches applied promptly
- [ ] Logs reviewed regularly
- [ ] Failed login attempts monitored
- [ ] Firewall rules reviewed
- [ ] Unnecessary services disabled
- [ ] SSH keys rotated periodically
- [ ] Backups configured and tested

### Production Additions

- [ ] Fail2Ban installed and configured
- [ ] Automatic security updates enabled
- [ ] SSL/TLS configured (reverse proxy)
- [ ] Intrusion detection system (IDS) considered
- [ ] Log aggregation and monitoring
- [ ] Alerting configured
- [ ] Incident response plan documented
- [ ] Regular security audits scheduled

## Security Incident Response

### If Compromised

1. **Isolate**: Disconnect from network
2. **Assess**: Determine scope of compromise
3. **Contain**: Stop malicious processes
4. **Eradicate**: Remove malware/backdoors
5. **Recover**: Restore from clean backup
6. **Review**: Analyze how breach occurred
7. **Improve**: Implement additional controls

### Emergency Contacts

- DigitalOcean Support: https://www.digitalocean.com/support
- Security Team: [Your team contact]

## Additional Resources

- [DigitalOcean Security Best Practices](https://www.digitalocean.com/community/tutorials/recommended-security-measures-to-protect-your-servers)
- [CIS Ubuntu Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SSH Hardening Guide](https://www.ssh.com/academy/ssh/sshd_config)

---

**Remember**: Security is an ongoing process, not a one-time setup. Regular reviews and updates are essential.
