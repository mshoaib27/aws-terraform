# Variable Passing Strategy - Decision Matrix

## TL;DR (Quick Answer)

| Scenario | Method | Command |
|----------|--------|---------|
| **Team/Production** | TFVARS file | `terraform plan -var-file="tfvars/uat.tfvars"` |
| **Sensitive data** | Multiple TFVARS | `terraform plan -var-file="tfvars/uat.tfvars" -var-file="tfvars/secrets.tfvars"` |
| **CI/CD** | Env vars + TFVARS | `TF_VAR_password=xxx terraform plan -var-file="tfvars/uat.tfvars"` |
| **One-off override** | CLI flags | `terraform plan -var-file="tfvars/uat.tfvars" -var="environment=test"` |
| **Manual input** | Interactive | `terraform plan` (DON'T USE - error-prone) |

---

## Recommendation for Your Project

### ✅ BEST PRACTICE: Hybrid Approach

**Use TFVARS for non-sensitive variables + Environment Variables for secrets:**

```bash
# Create secrets.tfvars (GITIGNORED)
cat > tfvars/secrets.tfvars << EOF
master_password = "YourSecurePassword123!@#"
EOF

# Deploy with both files
terraform plan \
  -var-file="tfvars/uat.tfvars" \
  -var-file="tfvars/secrets.tfvars"
```

### Why This Approach?

1. **Security** ✅
   - Sensitive data NOT in git
   - Passwords/keys in separate file
   - Easy to add .gitignore rule

2. **Team Collaboration** ✅
   - Non-sensitive values versioned
   - Each team member can use their own secrets.tfvars
   - No merge conflicts on shared tfvars

3. **CI/CD Ready** ✅
   - Secrets injected from CI/CD platform
   - No hardcoded credentials
   - Audit trail for all changes

4. **Reproducibility** ✅
   - Same tfvars = same deployment
   - Environment parity (dev/uat/prod)
   - Easy rollback

---

## Your Current Setup

```
tfvars/
├── uat.tfvars           ✅ Version controlled (public)
├── prod.tfvars          ✅ Version controlled (public)
├── dev.tfvars           ✅ Version controlled (public)
├── preprod.tfvars       ✅ Version controlled (public)
├── secrets.tfvars       ❌ GITIGNORED (local only)
└── secrets.tfvars.example  ✅ Template only
```

### File Contents

**uat.tfvars** (Committed - NO SECRETS)
```hcl
region                   = "eu-west-1"
environment              = "uat"
alb_name                 = "tt-uat-alb"
rds_instance_class       = "db.m5.large"
rds_allocated_storage    = 60
certificate_arn          = "arn:aws:acm:eu-west-1:419344669752:certificate/a5bf83b8-e069-4094-9c48-9e5bfb4c5928"
tags = {
  Environment = "uat"
  Project     = "tt-qatar"
}
```

**secrets.tfvars** (Gitignored - SECRETS ONLY)
```hcl
master_password = "Change123!@#"
```

---

## Implementation Examples

### Example 1: Local Development
```bash
# Copy template
cp tfvars/secrets.tfvars.example tfvars/secrets.tfvars

# Edit with your values
nano tfvars/secrets.tfvars

# Plan with both files
terraform plan -var-file="tfvars/dev.tfvars" -var-file="tfvars/secrets.tfvars"
```

### Example 2: CI/CD Pipeline (GitHub Actions)
```yaml
- name: Terraform Plan
  run: terraform plan -var-file="tfvars/uat.tfvars"
  env:
    TF_VAR_master_password: ${{ secrets.DB_PASSWORD }}
    TF_VAR_certificate_arn: ${{ secrets.ACM_CERT_ARN }}
```

### Example 3: CI/CD Pipeline (Bitbucket)
```yaml
definitions:
  steps:
    - step: &terraform-plan
        script:
          - terraform plan -var-file="tfvars/uat.tfvars"
        env:
          TF_VAR_master_password: $DB_PASSWORD
          TF_VAR_certificate_arn: $ACM_CERT_ARN
```

---

## NEVER DO THIS ❌

```bash
# ❌ Don't: Interactive input (error-prone, not reproducible)
terraform plan

# ❌ Don't: Hardcode secrets in TFVARS (commits to git!)
# master_password = "SecretPassword123"

# ❌ Don't: Pass secrets via CLI (visible in shell history)
terraform plan -var="master_password=secret123"

# ❌ Don't: Mix public and secrets in same file
# secrets.tfvars with both passwords AND region names

# ❌ Don't: Commit secrets.tfvars to git
git add tfvars/secrets.tfvars  # NEVER!
```

---

## Migration Path

If you're currently using variables incorrectly:

### Step 1: Audit Current Setup
```bash
git log --all -- "*.tfvars" | grep -i password
```

### Step 2: Extract Secrets
Move sensitive variables from uat.tfvars to secrets.tfvars

### Step 3: Update .gitignore
```bash
echo "tfvars/secrets.tfvars" >> .gitignore
```

### Step 4: Clean Git History (if secrets leaked)
```bash
# Using BFG Repo Cleaner
bfg --delete-files secrets.tfvars
```

---

## Summary

| Aspect | TFVARS | Manual Input | CLI Flags | Env Vars |
|--------|--------|--------------|-----------|----------|
| **Security** | Medium | Low | Low | High |
| **Team-friendly** | ✅ High | ❌ Low | ⚠️ Medium | ✅ High |
| **CI/CD** | ✅ Great | ❌ Poor | ⚠️ OK | ✅ Great |
| **Reproducible** | ✅ Yes | ❌ No | ⚠️ Maybe | ✅ Yes |
| **Audit trail** | ✅ Yes | ❌ No | ❌ No | ⚠️ Partial |
| **Ease of use** | ✅ Easy | ❌ Hard | ⚠️ Tedious | ✅ Easy |

**Verdict:** Use TFVARS for everything except secrets → Use env vars for secrets ⭐
