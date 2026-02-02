# Bitbucket Pipeline Configuration - Multi-Tenant Setup

## Pipeline Structure Overview

For 20 customers with 5 environments each (100 total pipelines), add the following to `bitbucket-pipelines.yml`:

## Step Anchors (Reusable)

Define these step anchors once at the top of the file:

```yaml
definitions:
  steps:
    - step: &terraform_init
        name: "Terraform Init"
        script:
          - echo "Initializing Terraform for $CUSTOMER_NAME/$ENVIRONMENT"
          - terraform init -backend-config="bucket=$TF_BACKEND_BUCKET" -backend-config="key=$CUSTOMER_NAME/$ENVIRONMENT/terraform.tfstate" -backend-config="region=$AWS_DEFAULT_REGION" -backend-config="dynamodb_table=$TF_LOCK_TABLE"
    
    - step: &terraform_validate
        name: "Validate Terraform"
        script:
          - terraform validate
          - terraform fmt -check
    
    - step: &terraform_plan
        name: "Terraform Plan"
        trigger: manual
        script:
          - terraform plan -var-file="tfvars/$ENVIRONMENT.tfvars" -out=tfplan_$CUSTOMER_NAME_$ENVIRONMENT
        artifacts:
          - tfplan_$CUSTOMER_NAME_$ENVIRONMENT
    
    - step: &terraform_apply
        name: "Terraform Apply"
        trigger: manual
        script:
          - terraform apply -auto-approve tfplan_$CUSTOMER_NAME_$ENVIRONMENT
        artifacts:
          - tfplan_$CUSTOMER_NAME_$ENVIRONMENT
    
    - step: &terraform_cost
        name: "Terraform Cost Estimation"
        script:
          - terraform plan -var-file="tfvars/$ENVIRONMENT.tfvars" -json | jq '.resource_changes[] | select(.change.actions | length > 0) | {address: .address, actions: .change.actions}'
```

## Custom Pipelines for Customer-1

```yaml
pipelines:
  custom:
    Customer-1-DEV:
      variables:
        - name: CUSTOMER_NAME
          default: "customer1"
        - name: ENVIRONMENT
          default: "dev"
        - name: AWS_ACCOUNT_ID
        - name: AWS_DEFAULT_REGION
          default: "eu-west-1"
        - name: AWS_OIDC_ROLE_ARN
        - name: TF_BACKEND_BUCKET
        - name: TF_LOCK_TABLE
          default: "terraform-locks"
      - step: *terraform_validate
      - step: *terraform_init
      - step: *terraform_plan
      - step: *terraform_cost
      - step: *terraform_apply

    Customer-1-QA:
      variables:
        - name: CUSTOMER_NAME
          default: "customer1"
        - name: ENVIRONMENT
          default: "qa"
        - name: AWS_ACCOUNT_ID
        - name: AWS_DEFAULT_REGION
          default: "eu-west-1"
        - name: AWS_OIDC_ROLE_ARN
        - name: TF_BACKEND_BUCKET
        - name: TF_LOCK_TABLE
          default: "terraform-locks"
      - step: *terraform_validate
      - step: *terraform_init
      - step: *terraform_plan
      - step: *terraform_cost
      - step: *terraform_apply

    # Repeat for UAT, PREPROD, PROD with appropriate environment values
```

## Adding Customer-2 to Customer-20

For each customer N from 2 to 20, duplicate the above structure for all 5 environments (DEV, QA, UAT, PREPROD, PROD):

```yaml
    Customer-N-DEV:
      variables:
        - name: CUSTOMER_NAME
          default: "customerN"  # Replace N with customer number
        - name: ENVIRONMENT
          default: "dev"
        - name: AWS_ACCOUNT_ID
        - name: AWS_DEFAULT_REGION
          default: "eu-west-1"
        - name: AWS_OIDC_ROLE_ARN
        - name: TF_BACKEND_BUCKET
        - name: TF_LOCK_TABLE
          default: "terraform-locks"
      - step: *terraform_validate
      - step: *terraform_init
      - step: *terraform_plan
      - step: *terraform_cost
      - step: *terraform_apply

    # Customer-N-QA, Customer-N-UAT, Customer-N-PREPROD, Customer-N-PROD
```

## Variables to Set in Bitbucket

For each custom pipeline, set these repository variables:

### Customer-1
- `AWS_ACCOUNT_ID`: 111111111111
- `AWS_OIDC_ROLE_ARN`: arn:aws:iam::111111111111:role/bitbucket-oidc-terraform-role
- `TF_BACKEND_BUCKET`: customer1-terraform-backend

### Customer-2
- `AWS_ACCOUNT_ID`: 222222222222
- `AWS_OIDC_ROLE_ARN`: arn:aws:iam::222222222222:role/bitbucket-oidc-terraform-role
- `TF_BACKEND_BUCKET`: customer2-terraform-backend

### ... and so on for Customer-3 through Customer-20

## State File Location

All state files stored in central backend:

```
s3://central-terraform-backend/
 customer1/dev/terraform.tfstate
 customer1/qa/terraform.tfstate
 customer1/uat/terraform.tfstate
 customer1/preprod/terraform.tfstate
 customer1/prod/terraform.tfstate
 customer2/dev/terraform.tfstate
 ...
 customer20/prod/terraform.tfstate
```

## Security Configuration

Each customer AWS account needs:
1. OIDC Provider configured for Bitbucket
2. IAM Role: `bitbucket-oidc-terraform-role`
3. Trust relationship to Bitbucket workspace
4. Attached policy: See `iam-policy-terraform-oidc.json`

## Environment Variables in tfvars

Create or update `tfvars/{environment}.tfvars`:

```hcl
# tfvars/dev.tfvars
customer_name = var.customer_name  # From Bitbucket variable
environment = "dev"
region = "eu-west-1"
ec2_app_count = 1
rds_multi_az = false
```

## Usage

1. Go to Bitbucket  Pipelines
2. Click "Create Custom Pipeline"
3. Select "Customer-1-DEV" (or any customer-environment pair)
4. Pipeline runs: Validate  Init  Plan  Cost Estimate
5. Review plan output
6. Click "Run Terraform Apply" for manual approval and deployment

## Cost: ~0 additional setup as all infrastructure already exists

The multi-tenant pipeline leverages existing:
- Bitbucket repo (already set up)
- Terraform code (modular, reusable)
- AWS accounts (one per customer)
- Backend storage (centralized S3)

Just add pipeline definitions and set variables per customer.
