# AWS OIDC Setup for GitHub Actions - Complete Manual Guide

## Overview

This guide walks you through setting up GitHub Actions to deploy Terraform to your AWS account using OIDC (OpenID Connect) - no long-lived AWS credentials needed!

**Your Details**:
- AWS Region: us-east-1
- Repository: mshoaib27/aws-terraform
- Method: OIDC (secure, temporary credentials)

---

## Step 1: Get Your AWS Account ID

First, find your AWS account ID.

### Option A: AWS Console
1. Sign in to AWS Console
2. Click your account name (top-right)
3. Copy the **Account ID** (12 digits like `123456789012`)

### Option B: AWS CLI
```bash
aws sts get-caller-identity --query Account --output text
```

**Save this**: Your AWS Account ID = `YOUR_ACCOUNT_ID`

---

## Step 2: Create OIDC Provider in AWS

This tells AWS to trust GitHub Actions tokens.

### Via AWS Console:

1. Go to **IAM**  **Identity providers**
2. Click **Add provider**
3. Select **OpenID Connect**
4. Fill in:
   - **Provider URL**: `https://token.actions.githubusercontent.com`
   - **Audience**: `sts.amazonaws.com`
5. Click **Get thumbprint** (auto-populates)
6. Click **Add provider**

### Via AWS CLI:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region us-east-1
```

**Expected Output**:
```
{
    "OpenIDConnectProviderArn": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
}
```

**Save this**: OIDC Provider ARN

---

## Step 3: Create IAM Role for GitHub

This role will be assumed by GitHub Actions.

**Important**: You do NOT need a GitHub organization to create this role. The organization/repository name is only specified in the trust policy conditions (not during role creation). If AWS console asks for an organization, just skip it or leave it blank.

### Via AWS Console:

1. Go to **IAM**  **Roles**  **Create role**
2. Select **Web identity**
3. For **Identity provider**, choose the OIDC provider you just created
4. For **Audience**, select `sts.amazonaws.com`
5. Click **Next**
6. **Skip permissions for now** (we'll add them later)  Click **Next**
7. **Role name**: `github-actions-terraform-role`
8. Click **Create role**
9. Go back to the role and edit the **Trust relationship**

### Via AWS CLI:

First, create a trust policy file. Replace `YOUR_ACCOUNT_ID` with your actual account ID:

```bash
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:mshoaib27/aws-terraform:*"
        }
      }
    }
  ]
}
EOF
```

Then create the role:

```bash
aws iam create-role \
  --role-name github-actions-terraform-role \
  --assume-role-policy-document file://trust-policy.json \
  --region us-east-1
```

**Expected Output**:
```
{
    "Role": {
        "RoleName": "github-actions-terraform-role",
        "Arn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-terraform-role",
        ...
    }
}
```

**Save this**: Role ARN = `arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-terraform-role`

---

## Step 4: Attach Permissions Policy

The role needs permissions to deploy Terraform infrastructure.

### Option A: AWS CLI

```bash
# Attach the policy file from your repo
aws iam put-role-policy \
  --role-name github-actions-terraform-role \
  --policy-name terraform-permissions \
  --policy-document file://iam-policy-terraform-oidc.json \
  --region us-east-1
```

### Option B: AWS Console (Quick)

1. Go to **IAM**  **Roles**  `github-actions-terraform-role`
2. Click **Add permissions**  **Attach policies**
3. Search for and attach:
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonEFSFullAccess`
   - `ElasticLoadBalancingFullAccess`
   - `IAMFullAccess`
   - `CloudWatchFullAccess`
   - `AmazonSNSFullAccess`
   - `AWSLambdaFullAccess`
   - `AWSCertificateManagerFullAccess`

Then add S3 and DynamoDB permissions (see Step 5).

---

## Step 5: Add Inline S3 & DynamoDB Policy

Your Terraform state files need S3 and DynamoDB access.

### Via AWS CLI:

```bash
cat > s3-dynamodb-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3BackendAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::*-terraform-backend",
        "arn:aws:s3:::*-terraform-backend/*"
      ]
    },
    {
      "Sid": "DynamoDBStateLocking",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:*:table/terraform-locks"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name github-actions-terraform-role \
  --policy-name s3-dynamodb-policy \
  --policy-document file://s3-dynamodb-policy.json \
  --region us-east-1
```

### Via AWS Console:

1. Go to **IAM**  **Roles**  `github-actions-terraform-role`
2. Click **Add permissions**  **Create inline policy**
3. Select **JSON** tab
4. Copy the S3/DynamoDB policy above
5. Click **Review policy**
6. Name: `s3-dynamodb-policy`
7. Click **Create policy**

---

## Step 6: Create S3 Backend Bucket

Your Terraform state will be stored here.

### Via AWS CLI:

```bash
# Create bucket (must be globally unique)
aws s3api create-bucket \
  --bucket your-terraform-backend-us-east-1 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-backend-us-east-1 \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-backend-us-east-1 \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket your-terraform-backend-us-east-1 \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Via AWS Console:

1. Go to **S3**  **Create bucket**
2. Name: `your-terraform-backend-us-east-1` (must be unique globally)
3. Region: **us-east-1**
4. Click **Create**
5. Select the bucket  **Properties**:
   - Enable **Versioning**
   - Enable **Default encryption** (AES-256)
6. Go to **Permissions**  **Block public access**  Enable all

**Save this**: Bucket name = `your-terraform-backend-us-east-1`

---

## Step 7: Create DynamoDB State Lock Table

This prevents concurrent Terraform modifications.

### Via AWS CLI:

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### Via AWS Console:

1. Go to **DynamoDB**  **Tables**  **Create table**
2. Table name: `terraform-locks`
3. Partition key: `LockID` (String)
4. Leave defaults (On-demand billing is fine)
5. Click **Create**

**Save this**: Table name = `terraform-locks`

---

## Step 8: Add GitHub Repository Secrets

GitHub needs to know your AWS details.

### Steps:

1. Go to your **GitHub repository**: https://github.com/mshoaib27/aws-terraform
2. Click **Settings** (repo settings, not your account)
3. Click **Secrets and variables**  **Actions**
4. Click **New repository secret**

### Add These 4 Secrets:

**Secret 1: AWS_ACCOUNT_ID**
- Name: `AWS_ACCOUNT_ID`
- Value: Your 12-digit AWS account ID (e.g., `123456789012`)

**Secret 2: AWS_OIDC_ROLE_ARN**
- Name: `AWS_OIDC_ROLE_ARN`
- Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-terraform-role`

**Secret 3: TF_BACKEND_BUCKET**
- Name: `TF_BACKEND_BUCKET`
- Value: `your-terraform-backend-us-east-1`

**Secret 4: TF_LOCK_TABLE**
- Name: `TF_LOCK_TABLE`
- Value: `terraform-locks`

---

## Step 9: Update Workflow for us-east-1

The workflow file is currently set for eu-west-1. Let''s update it.

Replace the AWS_REGION in `.github/workflows/terraform-deploy.yml`:

**Find this**:
```yaml
env:
  AWS_REGION: eu-west-1
  TERRAFORM_VERSION: 1.12.1
```

**Replace with**:
```yaml
env:
  AWS_REGION: us-east-1
  TERRAFORM_VERSION: 1.12.1
```

---

## Step 10: Test the Setup

### Test 1: Verify AWS Credentials Work

```bash
# Test assuming the role (requires AWS CLI configured)
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-terraform-role \
  --role-session-name github-actions \
  --web-identity-token YOUR_GITHUB_TOKEN \
  --region us-east-1
```

### Test 2: Push Code to Trigger Workflow

```bash
# Make a small change
git add .
git commit -m "test: Update workflow for us-east-1"
git push origin main

# Watch it run at: https://github.com/mshoaib27/aws-terraform/actions
```

The workflow should now:
1.  Format check
2.  Terraform init (without backend)
3.  Terraform validate
4.  Terraform plan (with AWS credentials)
5.  Security scans

---

## Step 11: Monitor Execution

1. Go to **GitHub**  your repo  **Actions** tab
2. Click the latest workflow run
3. Click each job to see logs
4. Check for:
   -  Green checkmarks (success)
   -  Red X (failure)
   -  Logs for errors

---

## Troubleshooting

### Error: "Role not found"
- **Cause**: Role ARN incorrect or role doesn''t exist
- **Fix**: Verify role exists in IAM dashboard
- **Test**: `aws iam get-role --role-name github-actions-terraform-role`

### Error: "Access denied on S3"
- **Cause**: S3 bucket name in secret doesn''t match actual bucket
- **Fix**: Check S3 bucket name: `aws s3 ls`
- **Re-add**: Update `TF_BACKEND_BUCKET` secret

### Error: "OIDC provider not found"
- **Cause**: Provider wasn''t created in Step 2
- **Fix**: Create provider again
- **Verify**: `aws iam list-open-id-connect-providers`

### Error: "State lock timeout"
- **Cause**: DynamoDB table doesn''t exist
- **Fix**: Create table in Step 7
- **Verify**: `aws dynamodb describe-table --table-name terraform-locks`

---

## What Just Happened (Learning Points)

 **OIDC Provider**: Told AWS to trust GitHub''s tokens  
 **IAM Role**: Created a role GitHub can assume  
 **Trust Relationship**: Limited role to only your repo  
 **Permissions**: Gave role power to deploy infrastructure  
 **S3 Backend**: Central state storage with versioning  
 **DynamoDB Locking**: Prevents concurrent modifications  
 **GitHub Secrets**: Securely passed AWS config to Actions  
 **No Credentials**: Used OIDC instead of AWS keys  

---

## Next Deployments

Now your workflow is ready! Every time you:

1. **Push to main**  Automatic deploy
2. **Create PR**  Shows plan in PR comments
3. **Manual trigger**  Deploy specific environment

**Test it now**: `git push origin main`

---

## Quick Reference

```bash
# Get your account ID
aws sts get-caller-identity

# Check OIDC provider exists
aws iam list-open-id-connect-providers

# Check role exists
aws iam get-role --role-name github-actions-terraform-role

# Check S3 bucket
aws s3 ls

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-locks

# Check role policies
aws iam list-role-policies --role-name github-actions-terraform-role
```


