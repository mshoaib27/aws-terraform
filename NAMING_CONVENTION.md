# Resource Naming Convention Guide

## Format

All resources follow this naming convention:
```
{customer_name}-{environment}-{resource_type}[-{index}]
```

### Examples
- **App Servers:** `tt-uat-app-01`, `tt-uat-app-02`, `tt-uat-app-03`
- **Cron Servers:** `tt-uat-cron-01`, `tt-uat-cron-02`
- **API Servers:** `tt-uat-api-01`, `tt-uat-api-02`
- **Jumper/Bastion:** `tt-uat-jumper`
- **RDS Database:** `tt-uat-db`
- **EFS Filesystem:** `tt-uat-efs`
- **ALB:** `tt-uat-alb`
- **VPC:** `tt-uat-vpc`

---

## Naming Convention Variables

Set these in your `tfvars` file:

```hcl
# Naming
customer_name   = "tt"          # Your company/project abbreviation
environment     = "uat"         # dev, uat, staging, preprod, prod

# Server Counts (incremental naming auto-generated)
app_server_count    = 1         # Creates: tt-uat-app-01
cron_server_count   = 1         # Creates: tt-uat-cron-01
api_server_count    = 2         # Creates: tt-uat-api-01, tt-uat-api-02

# Instance Types
app_server_instance_type    = "m5.large"
cron_server_instance_type   = "t3.medium"
api_server_instance_type    = "m5.xlarge"
jumper_server_instance_type = "t3.small"
```

---

## Complete Resource Naming Map

### EC2 Instances

| Type | Pattern | Count | Examples |
|------|---------|-------|----------|
| Application | `{prefix}-app-{02d}` | app_server_count | tt-uat-app-01, tt-uat-app-02 |
| Cron/Scheduler | `{prefix}-cron-{02d}` | cron_server_count | tt-uat-cron-01, tt-uat-cron-02 |
| API | `{prefix}-api-{02d}` | api_server_count | tt-uat-api-01, tt-uat-api-02 |
| Jumper/Bastion | `{prefix}-jumper` | 1 | tt-uat-jumper |

### Data & Storage

| Resource | Name Pattern | Example |
|----------|--------------|---------|
| RDS Instance | `{prefix}-db` | tt-uat-db |
| RDS Subnet Group | `{prefix}-db-subnet-group` | tt-uat-db-subnet-group |
| RDS Parameter Group | `{prefix}-params` | tt-uat-params |
| RDS Option Group | `{prefix}-options` | tt-uat-options |
| EFS | `{prefix}-efs` | tt-uat-efs |
| EFS Mount Target | `{prefix}-efs-mount` | tt-uat-efs-mount |

### Networking

| Resource | Name Pattern | Example |
|----------|--------------|---------|
| VPC | `{prefix}-vpc` | tt-uat-vpc |
| NAT Gateway | `{prefix}-nat` | tt-uat-nat |
| Internet Gateway | `{prefix}-igw` | tt-uat-igw |
| ALB | `{prefix}-alb` | tt-uat-alb |
| ALB Target Group | `{prefix}-alb-tg` | tt-uat-alb-tg |

### Security Groups

| Resource | Name Pattern | Example |
|----------|--------------|---------|
| RDS | `{prefix}-rds-sg` | tt-uat-rds-sg |
| EC2 | `{prefix}-ec2-sg` | tt-uat-ec2-sg |
| ALB | `{prefix}-alb-sg` | tt-uat-alb-sg |
| Jumper | `{prefix}-jumper-sg` | tt-uat-jumper-sg |
| EFS | `{prefix}-efs-sg` | tt-uat-efs-sg |

### IAM

| Resource | Name Pattern | Example |
|----------|--------------|---------|
| EC2 SSM Role | `{prefix}-ec2-ssm-role` | tt-uat-ec2-ssm-role |
| EC2 Instance Profile | `{prefix}-ec2-ssm-profile` | tt-uat-ec2-ssm-profile |

---

## How to Use

### Step 1: Define in tfvars

```hcl
# tfvars/uat.tfvars
customer_name = "tt"
environment   = "uat"

# Create 2 app servers, 1 cron, 1 API server
app_server_count  = 2
cron_server_count = 1
api_server_count  = 1
```

### Step 2: Resources Auto-Generated

With the configuration above, Terraform will automatically create:
- `tt-uat-app-01` (m5.large)
- `tt-uat-app-02` (m5.large)
- `tt-uat-cron-01` (t3.medium)
- `tt-uat-api-01` (m5.xlarge)
- `tt-uat-jumper` (t3.small)
- `tt-uat-db` (RDS)
- `tt-uat-efs` (EFS)
- `tt-uat-alb` (ALB)
- And all supporting resources

### Step 3: Deploy

```bash
terraform plan -var-file="tfvars/uat.tfvars"
terraform apply -var-file="tfvars/uat.tfvars"
```

---

## Environment Examples

### Development Environment
```hcl
# tfvars/dev.tfvars
customer_name       = "tt"
environment         = "dev"
app_server_count    = 1
cron_server_count   = 0
api_server_count    = 1
```
Creates: `tt-dev-app-01`, `tt-dev-api-01`, `tt-dev-jumper`

### UAT Environment
```hcl
# tfvars/uat.tfvars
customer_name       = "tt"
environment         = "uat"
app_server_count    = 2
cron_server_count   = 1
api_server_count    = 2
```
Creates: `tt-uat-app-01`, `tt-uat-app-02`, `tt-uat-cron-01`, `tt-uat-api-01`, `tt-uat-api-02`, `tt-uat-jumper`

### Production Environment
```hcl
# tfvars/prod.tfvars
customer_name       = "tt"
environment         = "prod"
app_server_count    = 3
cron_server_count   = 2
api_server_count    = 3
app_server_instance_type    = "m5.xlarge"
api_server_instance_type    = "c5.2xlarge"
```
Creates: `tt-prod-app-01`, `tt-prod-app-02`, `tt-prod-app-03`, `tt-prod-cron-01`, `tt-prod-cron-02`, `tt-prod-api-01`, `tt-prod-api-02`, `tt-prod-api-03`, `tt-prod-jumper`

---

## Index Formatting

Indexes are formatted as `{02d}` (zero-padded 2 digits):
- 1st server: `01`
- 2nd server: `02`
- ...
- 9th server: `09`
- 10th server: `10`

Examples:
- `tt-uat-app-01`, `tt-uat-app-02`, `tt-uat-app-03`, ..., `tt-uat-app-09`, `tt-uat-app-10`

---

## Validation Rules

The system validates:
- `app_server_count`: 0-10
- `cron_server_count`: 0-5
- `api_server_count`: 0-10
- `environment`: dev, uat, staging, preprod, prod

---

## Changing Counts

To add/remove servers, just update your tfvars:

```bash
# Original: 1 app server
app_server_count = 1

# New: 2 app servers
app_server_count = 2

# Run terraform
terraform plan -var-file="tfvars/uat.tfvars"
# Will show: 1 resource to add (tt-uat-app-02)
```

---

## Key Benefits

✅ **Consistent naming** across all environments  
✅ **Scalable** - easily add/remove servers by changing count  
✅ **Incremental** - servers numbered automatically (01, 02, 03...)  
✅ **Environment-aware** - different names for dev/uat/prod  
✅ **Easy identification** - server type visible in name  
✅ **Infrastructure-as-Code** - all names defined in code  
