# GitHub Actions Setup for AWS Terraform Deployment

## Prerequisites

1. **GitHub Repository**: Your Terraform code pushed to GitHub (already done: mshoaib27/aws-terraform)
2. **AWS Account**: Access to configure OIDC and IAM roles
3. **AWS CLI** (optional, for manual setup)

## Step 1: Create OIDC Provider in AWS

Run this in your AWS account (using AWS CLI or Console):

```bash
# Set variables
GITHUB_OWNER="mshoaib27"
GITHUB_REPO="aws-terraform"
GITHUB_REPO_FULL="${GITHUB_OWNER}/${GITHUB_REPO}"

# Create OIDC Provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## Step 2: Create IAM Role for GitHub Actions

```bash
# Create trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO_FULL}:*"
        }
      }
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name github-actions-terraform-role \
  --assume-role-policy-document file://trust-policy.json

# Attach permissions policy
aws iam put-role-policy \
  --role-name github-actions-terraform-role \
  --policy-name terraform-permissions \
  --policy-document file://iam-policy-terraform-oidc.json
```

## Step 3: Set GitHub Repository Secrets

In your GitHub repo, go to **Settings  Secrets and variables  Actions** and add:

```
AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID (e.g., 419344669752)
AWS_OIDC_ROLE_ARN=arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/github-actions-terraform-role
TF_BACKEND_BUCKET=your-terraform-backend-bucket
TF_LOCK_TABLE=terraform-locks
```

## Step 4: GitHub Actions Workflow

The workflow file (`.github/workflows/terraform-deploy.yml`) is already created with:

### Triggers:
- **Pull Request**: Runs terraform plan on PRs to main
- **Push to main**: Automatically runs terraform apply
- **Manual trigger**: Run plan/apply/destroy for any environment

### Jobs:

1. **terraform-plan**: 
   - Validates code formatting
   - Initializes Terraform
   - Creates and uploads plan file
   - Comments plan output on PRs

2. **terraform-apply**:
   - Runs only on pushes to main (with approval required)
   - Applies the plan from PR validation
   - Creates deployment record

3. **terraform-manual-deploy**:
   - Triggered manually via GitHub Actions UI
   - Select environment (dev/qa/uat/preprod/prod)
   - Select action (plan/apply/destroy)

4. **security-scan**:
   - Runs TFLint for policy enforcement
   - Runs Checkov for security scanning

## Step 5: How to Use

### Option A: Automatic Deployment
1. Push code to main branch
2. GitHub Actions automatically:
   - Validates and plans changes
   - Creates a deployment record
   - Applies infrastructure

### Option B: Pull Request Review
1. Create a feature branch
2. Push changes and create a PR
3. GitHub Actions shows plan in PR comments
4. Review changes
5. Merge to main  automatic apply

### Option C: Manual Deployment
1. Go to GitHub repo  Actions
2. Select "Terraform Deploy" workflow
3. Click "Run workflow"
4. Choose environment and action
5. Approve and deploy

## Troubleshooting

| Issue | Solution |
|-------|----------|
| OIDC provider not found | Verify provider URL in trust policy |
| Permission denied on S3 | Check IAM policy has s3:GetObject, s3:PutObject |
| State lock timeout | Increase lock timeout or check DynamoDB |
| Plan file not found | Ensure artifacts are uploaded correctly |

## Security Best Practices

 No AWS credentials stored in GitHub  
 OIDC for temporary, short-lived credentials  
 Environment approvals before production deploys  
 Audit trail in GitHub Actions logs  
 TFLint and Checkov scans on every run  
 State locked with DynamoDB  

## Cost Estimation

GitHub Actions free tier includes:
- 2,000 minutes/month on public repos (unlimited)
- Sufficient for most Terraform deployments
- No additional costs for AWS deployments

