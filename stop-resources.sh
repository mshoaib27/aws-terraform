#!/bin/bash
# Script to stop all UAT infrastructure resources without terminating

echo "Stopping all UAT Infrastructure Resources..."
echo "=============================================="

# Stop EC2 Instances
echo ""
echo "1. Stopping EC2 Instances..."
aws ec2 stop-instances --instance-ids i-0cd9b9ff2a96e8b95 i-042a66c31a6166a1a --region eu-west-1
echo "   ✓ EC2 instances stopped (tt-uat-app, tt-uat-jumper)"

# Stop RDS Instance
echo ""
echo "2. Stopping RDS Database..."
aws rds stop-db-instance --db-instance-identifier db-3KEG3QWU3YUFZN5HTQDSYAKPU4 --region eu-west-1
echo "   ✓ RDS instance stopped"

# EFS will remain running (no stop option available, it's always available)
echo ""
echo "3. EFS Status..."
echo "   ℹ EFS filesystem is always available (cannot be stopped)"

# ALB will remain running 
echo ""
echo "4. ALB Status..."
echo "   ℹ ALB remains running (not stopped)"

# NAT Gateway will remain active
echo ""
echo "5. NAT Gateway Status..."
echo "   ℹ NAT Gateway remains active (incurring charges)"

echo ""
echo "=============================================="
echo "✓ All EC2 and RDS resources have been stopped"
echo "✓ Resources are NOT terminated - can be restarted anytime"
echo "=============================================="
echo ""
echo "To verify stopped resources:"
echo "  aws ec2 describe-instances --instance-ids i-0cd9b9ff2a96e8b95 i-042a66c31a6166a1a --region eu-west-1"
echo "  aws rds describe-db-instances --db-instance-identifier db-3KEG3QWU3YUFZN5HTQDSYAKPU4 --region eu-west-1"
echo ""
echo "To restart resources:"
echo "  terraform apply -var-file=\"tfvars/uat.tfvars\" -auto-approve"
