# Terraform Deployment Guide

## Quick Start

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Create Environment-Specific Variables
```bash
# For UAT environment
terraform plan -var-file="tfvars/uat.tfvars"

# For Production environment
terraform plan -var-file="tfvars/prod.tfvars"

# For Development environment
terraform plan -var-file="tfvars/dev.tfvars"
```

### 3. Deploy Infrastructure
```bash
# Plan first (always review)
terraform plan -var-file="tfvars/uat.tfvars" -out=tfplan

# Apply the plan
terraform apply tfplan
```

---

## Variable Passing Methods

### Method 1: TFVARS File (RECOMMENDED) ⭐
```bash
terraform plan -var-file="tfvars/uat.tfvars"
```
**Best for:** Production, teams, CI/CD pipelines

### Method 2: Multiple TFVARS Files (BEST PRACTICE)
```bash
# Combine non-sensitive + sensitive variables
terraform plan \
  -var-file="tfvars/uat.tfvars" \
  -var-file="tfvars/secrets.tfvars"
```
**Use case:** Separate public and sensitive configs

### Method 3: Command Line Variables
```bash
terraform plan \
  -var="region=eu-west-1" \
  -var="environment=uat" \
  -var="certificate_arn=arn:aws:acm:..."
```
**Best for:** Simple overrides, one-off deployments

### Method 4: Environment Variables
```bash
export TF_VAR_region="eu-west-1"
export TF_VAR_certificate_arn="arn:aws:acm:..."
terraform plan -var-file="tfvars/uat.tfvars"
```
**Best for:** CI/CD with secrets management, Docker

### Method 5: Interactive (AVOID)
```bash
terraform plan
# Manually enters each variable
```
**Avoid:** Error-prone, not reproducible, slow

---

## Project Structure

```
sba-terraform/
├── main.tf                 # Root module - orchestrates all modules
├── variables.tf            # All variable definitions
├── output.tf               # Root outputs
├── backend.tf              # S3 backend configuration
│
├── tfvars/
│   ├── dev.tfvars         # Development environment (COMMITTED ✅)
│   ├── uat.tfvars         # UAT environment (COMMITTED ✅)
│   ├── prod.tfvars        # Production environment (COMMITTED ✅)
│   ├── preprod.tfvars     # Pre-prod environment (COMMITTED ✅)
│   ├── secrets.tfvars     # Sensitive data (GITIGNORED ❌)
│   └── secrets.tfvars.example  # Template for secrets
│
├── Modules:
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   ├── efs/
│   ├── alb/
│   ├── sg/
│   ├── iam/
│   └── acm/
│
└── Scripts:
    ├── stop-resources.ps1
    └── stop-resources.sh
```

---

## Security Best Practices

### ✅ DO:
- ✅ Version control environment configs (dev/uat/prod)
- ✅ Use secrets management for sensitive data
- ✅ Use AWS Secrets Manager for database passwords
- ✅ Use AWS Systems Manager Parameter Store for configs
- ✅ Rotate credentials regularly
- ✅ Use IAM roles instead of access keys
- ✅ Enable MFA for sensitive operations

### ❌ DON'T:
- ❌ Commit passwords to git
- ❌ Commit API keys to git
- ❌ Commit certificate private keys to git
- ❌ Share tfvars files with sensitive data
- ❌ Use root AWS account for deployments
- ❌ Use static credentials in code

---

## CI/CD Integration Example

### GitHub Actions
```yaml
name: Terraform Deploy
on: [push]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: hashicorp/setup-terraform@v1
      
      - name: Terraform Init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Terraform Plan
        run: terraform plan -var-file="tfvars/uat.tfvars" -out=tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
          TF_VAR_certificate_arn: ${{ secrets.ACM_CERT_ARN }}
      
      - name: Terraform Apply
        run: terraform apply tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Bitbucket Pipelines (Your Current Setup)
```yaml
image: hashicorp/terraform:latest

pipelines:
  branches:
    development:
      - step:
          name: Terraform Plan UAT
          script:
            - terraform init
            - terraform plan -var-file="tfvars/uat.tfvars"
    main:
      - step:
          name: Terraform Plan Production
          script:
            - terraform init
            - terraform plan -var-file="tfvars/prod.tfvars"
          trigger: manual
```

---

## Deployment Scenarios

### Scenario 1: Deploy to UAT
```bash
# Step 1: Plan
terraform plan -var-file="tfvars/uat.tfvars" -out=uat.tfplan

# Step 2: Review the plan
cat uat.tfplan

# Step 3: Apply
terraform apply uat.tfplan
```

### Scenario 2: Deploy to Production with Secrets
```bash
# Step 1: Fetch secrets from AWS Secrets Manager
export TF_VAR_db_password=$(aws secretsmanager get-secret-value \
  --secret-id prod/rds/password \
  --query SecretString \
  --output text)

# Step 2: Plan
terraform plan \
  -var-file="tfvars/prod.tfvars" \
  -var-file="tfvars/secrets.tfvars" \
  -out=prod.tfplan

# Step 3: Apply with approval
terraform apply -auto-approve prod.tfplan
```

### Scenario 3: Stop Resources (Cost Optimization)
```bash
# Windows PowerShell
.\stop-resources.ps1

# Linux/Mac
bash stop-resources.sh
```

---

## Troubleshooting

### Problem: "Variable not defined"
**Solution:** Check if tfvars file is passed correctly
```bash
terraform plan -var-file="tfvars/uat.tfvars"
```

### Problem: "Cannot access S3 backend (403 Forbidden)"
**Solution:** Check AWS credentials
```bash
aws sts get-caller-identity
```

### Problem: "Sensitive data in git history"
**Solution:** Use git-filter-branch or BFG Repo Cleaner
```bash
bfg --delete-files secrets.tfvars
```

---

## Key Commands

```bash
# Initialize
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Plan with specific vars
terraform plan -var-file="tfvars/uat.tfvars"

# Apply with specific vars
terraform apply -var-file="tfvars/uat.tfvars"

# Destroy
terraform destroy -var-file="tfvars/uat.tfvars"

# Output values
terraform output

# State management
terraform state list
terraform state show <resource>
terraform state rm <resource>  # CAUTION!
```

---

## Current Infrastructure

### UAT Environment (Deployed ✅)
- VPC: 10.1.0.0/24 with NAT Gateway
- EC2: 2 instances (private app + public jumper)
- RDS: MySQL 8.0.44, 60GB
- ALB: HTTPS on port 443 → tt-uat-app:80
- EFS: Single-AZ, mounted to /data
- IAM: SSM Session Manager enabled

### Configuration
- Region: eu-west-1 (Ireland)
- Certificate ARN: arn:aws:acm:eu-west-1:419344669752:certificate/a5bf83b8-e069-4094-9c48-9e5bfb4c5928
