# Naming Convention - Quick Reference

## Your Convention
```
{customer_name}-{environment}-{resource_type}[-{index}]
```

## Configuration in tfvars

```hcl
customer_name           = "tt"
environment             = "uat"

# Server counts (auto-incremental naming)
app_server_count        = 2      # tt-uat-app-01, tt-uat-app-02
cron_server_count       = 1      # tt-uat-cron-01
api_server_count        = 1      # tt-uat-api-01

# Instance types
app_server_instance_type    = "m5.large"
cron_server_instance_type   = "t3.medium"
api_server_instance_type    = "m5.xlarge"
jumper_server_instance_type = "t3.small"
```

## Generated Resources

### EC2 Instances (with counts)
```
tt-uat-app-01    (m5.large)       ← 1st app server
tt-uat-app-02    (m5.large)       ← 2nd app server
tt-uat-cron-01   (t3.medium)      ← 1st cron server
tt-uat-api-01    (m5.xlarge)      ← 1st API server
tt-uat-jumper    (t3.small)       ← Bastion/Jumper
```

### RDS & Storage
```
tt-uat-db           (MySQL database)
tt-uat-db-subnet-group
tt-uat-params       (RDS parameters)
tt-uat-options      (RDS options)
tt-uat-efs          (EFS filesystem)
```

### Networking
```
tt-uat-vpc          (Virtual Private Cloud)
tt-uat-nat          (NAT Gateway)
tt-uat-igw          (Internet Gateway)
tt-uat-alb          (Application Load Balancer)
tt-uat-alb-tg       (ALB Target Group)
```

### Security Groups
```
tt-uat-rds-sg       (RDS security group)
tt-uat-ec2-sg       (EC2 security group)
tt-uat-alb-sg       (ALB security group)
tt-uat-jumper-sg    (Jumper security group)
tt-uat-efs-sg       (EFS security group)
```

### IAM
```
tt-uat-ec2-ssm-role      (EC2 SSM role)
tt-uat-ec2-ssm-profile   (Instance profile)
```

## How It Works

1. **Define counts in tfvars:**
   ```hcl
   app_server_count = 2
   ```

2. **Terraform auto-generates names:**
   - `locals.tf` creates: `app_server_names = ["tt-uat-app-01", "tt-uat-app-02"]`

3. **EC2 module uses for_each:**
   ```hcl
   for_each = toset(local.app_server_names)
   ```

4. **Result:** Both servers created with proper naming

## Scale Up/Down

To add more servers, just change counts:

```hcl
# Add one more app server
app_server_count = 3  # Creates tt-uat-app-03
```

Then run:
```bash
terraform plan -var-file="tfvars/uat.tfvars"
terraform apply -var-file="tfvars/uat.tfvars"
```

## Files

- **`locals.tf`** - Defines all naming logic
- **`variables.tf`** - Server counts and instance types
- **`tfvars/uat.tfvars`** - Your environment configuration
- **`NAMING_CONVENTION.md`** - Full documentation
