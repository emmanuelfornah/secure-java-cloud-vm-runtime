# Business Case: Secure Java Cloud VM Runtime

## Executive Summary

This project establishes a secure and automated baseline for deploying Java applications to Linux cloud virtual machines.

It demonstrates practical infrastructure engineering principles including:

- SSH hardening
- Least-privilege user design
- Firewall minimization
- System-level service orchestration
- Scripted, repeatable deployment workflows

The goal is to reduce operational risk while improving deployment consistency.

## Problem Context

Deploying applications directly to cloud VMs introduces several common risks:

### Security Risks
- Default root SSH access
- Password-based authentication exposure
- Excessive open network ports
- Applications running with elevated privileges

### Operational Risks
- Manual deployments causing drift
- Inconsistent configuration across environments
- Limited repeatability
- Lack of structured documentation

Even small systems benefit from a hardened baseline before scaling.

## Solution Overview

This repository implements:

### 1. Infrastructure Hardening
- Root SSH login disabled
- Key-based authentication enforced
- Non-root dedicated application user
- UFW configured with minimal required ports
- SystemD sandboxing options enabled

### 2. Deployment Automation
- Scripted Java runtime installation
- Automated user creation
- Application directory provisioning
- One-command deployment workflow
- Health verification checks

### 3. Operational Controls
- SystemD service with restart policies
- Structured logs via journalctl
- Predictable runtime directory structure
- Clear rollback path (artifact replacement)

## Engineering Impact

This project demonstrates:

- Reduction of common VM-level misconfigurations
- Elimination of root-level application execution
- Repeatable environment setup
- Clear separation between provisioning and runtime

It establishes a secure baseline that can evolve into:

- Containerized runtime
- Artifact repository integration
- CI/CD automation
- Infrastructure as Code with Terraform

## Architectural Layers

### Infrastructure
- DigitalOcean Ubuntu 22.04 LTS VM

### Security
- SSH hardening
- Key-only authentication
- UFW firewall
- Dedicated non-root runtime user

### Runtime
- Java 17
- Spring Boot application
- SystemD-managed service

### Automation
- Bash-based provisioning scripts
- Gradle artifact build process
- Health endpoint verification

## Strategic Positioning

This repository represents:

**A hardened VM runtime baseline suitable for small production workloads or controlled staging environments.**

It intentionally precedes:
- Containerization
- Registry management
- CI/CD orchestration
- Kubernetes deployment

By first establishing runtime security and operational clarity.

## Status

- Deployment validated
- Security controls verified
- Automation scripts functional
- Health checks operational
