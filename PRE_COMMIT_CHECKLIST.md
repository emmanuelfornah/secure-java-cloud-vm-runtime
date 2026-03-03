# Pre-Commit Security Checklist

## ⚠️ CRITICAL: Review Before Committing

### Sensitive Data Check

- [ ] No IP addresses in code (use YOUR_DROPLET_IP placeholder)
- [ ] No usernames in code (use YOUR_USERNAME placeholder)
- [ ] No passwords or API keys
- [ ] No SSH private keys
- [ ] No email addresses (except examples)
- [ ] No server hostnames
- [ ] No database connection strings
- [ ] No cloud provider credentials

### Files to Review

```bash
# Search for potential sensitive data
grep -r "164.90.218.238" .
grep -r "68.183.155.58" .
grep -r "emmanuel@" .
grep -r "password" .
grep -r "api_key" .
grep -r "secret" .
```

### .gitignore Verification

Ensure these patterns are in .gitignore:
- [ ] `*.local.sh` (local configuration)
- [ ] `config.local.sh` (user-specific config)
- [ ] `.env.local` (environment variables)
- [ ] `*.pem` (SSH keys)
- [ ] `*.key` (private keys)
- [ ] `id_rsa*` (SSH keys)
- [ ] `id_ed25519*` (SSH keys)

### Configuration Template

- [ ] `config.example.sh` exists with placeholders
- [ ] All scripts use placeholders or read from config
- [ ] Documentation uses generic examples

### Documentation Review

- [ ] README uses placeholder values
- [ ] DEPLOYMENT guide uses generic examples
- [ ] Architecture diagrams don't show real IPs
- [ ] QUICKSTART uses YOUR_DROPLET_IP

### Safe to Commit

If all checks pass:
```bash
git status
git add .
git commit -m "your message"
```

### If Sensitive Data Found

1. Remove sensitive data
2. Update with placeholders
3. Add pattern to .gitignore
4. Re-run this checklist

### Post-Commit Verification

After pushing:
```bash
# View your public repo
# Verify no sensitive data is visible
```

---

**Remember**: Once committed, data is in git history forever. Always check before pushing!
