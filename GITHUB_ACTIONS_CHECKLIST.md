# GitHub Actions + AWS OIDC Setup Checklist

## Quick Start (5 minutes)

This guides you through setting up GitHub Actions to automatically deploy Terraform to AWS.

## Step 1: AWS OIDC Provider Setup

Run this AWS CLI command in your AWS account:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region eu-west-1
```

**Expected Output**: OIDC Provider ARN
```
arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
```

 **Save this ARN** - you'll need it next

## Step 2: Create IAM Role

Replace `YOUR_AWS_ACCOUNT_ID` with your account ID (e.g., 419344669752):

```bash
# 1. Create trust policy file
cat > /tmp/trust-policy.json << 'EOF'
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
          "token.actions.githubusercontent.com:sub": "repo:mshoaib27/aws-terraform:*"
        }
      }
    }
  ]
}
EOF

# 2. Create the IAM role
aws iam create-role \
  --role-name github-actions-terraform-role \
  --assume-role-policy-document file:///tmp/trust-policy.json

# 3. Attach the permissions policy (already in iam-policy-terraform-oidc.json)
aws iam put-role-policy \
  --role-name github-actions-terraform-role \
  --policy-name terraform-permissions \
  --policy-document file://iam-policy-terraform-oidc.json
```

 **Role Created**: `github-actions-terraform-role`

## Step 3: Set GitHub Secrets

In your GitHub repository:

1. Go to **Settings**  **Secrets and variables**  **Actions**
2. Click **New repository secret**
3. Add these 4 secrets:

| Secret Name | Value |
|---|---|
| `AWS_ACCOUNT_ID` | Your AWS account ID (e.g., `419344669752`) |
| `AWS_OIDC_ROLE_ARN` | `arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/github-actions-terraform-role` |
| `TF_BACKEND_BUCKET` | Your S3 backend bucket name (e.g., `tasctower-terraform-backend`) |
| `TF_LOCK_TABLE` | DynamoDB table name (e.g., `terraform-locks`) |

 **All secrets set**

## Step 4: Verify AWS Backend

Ensure your S3 backend bucket and DynamoDB table exist:

```bash
# Check S3 bucket
aws s3 ls s3://tasctower-terraform-backend

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-locks
```

 **Backend verified**

## Step 5: Test the Workflow

Option A - **Automatic on Push**:
```bash
# Make a change to Terraform code
git add .
git commit -m "test: Update infrastructure"
git push origin main
# GitHub Actions will automatically run!
```

Option B - **Manual Trigger**:
1. Go to **Actions** tab in your GitHub repo
2. Select **Terraform Deploy**
3. Click **Run workflow**
4. Choose environment (dev/qa/uat/preprod/prod)
5. Choose action (plan/apply/destroy)
6. Click **Run**

 **Workflow triggered**

## Workflow Features

### Automatic on Push to Main
-  Format validation
-  Terraform validate
-  Terraform plan
-  Manual approval (production environment)
-  Terraform apply

### Automatic on Pull Request
-  Format validation
-  Terraform validate
-  Terraform plan
-  Comments plan in PR for review
-  TFLint & Checkov security scans

### Manual Trigger (workflow_dispatch)
-  Select environment
-  Select action (plan/apply/destroy)
-  Runs immediately

## File Structure

```
.github/workflows/
   terraform-deploy.yml      # Main workflow file
GITHUB_ACTIONS_SETUP.md         # Detailed setup guide
iam-policy-terraform-oidc.json  # IAM permissions policy
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "OIDC provider not found" | Run Step 1 AWS CLI command again |
| "Permission denied on S3" | Verify iam-policy is attached to role |
| "Workflow fails on format check" | Run `terraform fmt -recursive` locally |
| "Plan file not found in apply" | Check artifacts upload in Plan job |
| "Timeout on state lock" | Check if another workflow is running |

## Security Notes

 **No AWS credentials in GitHub** - Uses OIDC for temporary credentials  
 **Temporary credentials** - Valid for 1 hour, auto-revoked  
 **Audit trail** - All deployments logged in GitHub Actions  
 **PR approval** - Changes visible before merge  
 **Production gate** - Manual approval required for apply  
 **Encrypted state** - S3 state with DynamoDB locking  

## Next Steps

1.  AWS OIDC provider created
2.  IAM role created with permissions
3.  GitHub secrets configured
4.  Backend S3 & DynamoDB verified
5.  **Ready to deploy!**

Test with: `git push origin main` to trigger first deployment

---

**Questions?** Check GITHUB_ACTIONS_SETUP.md for detailed information.
