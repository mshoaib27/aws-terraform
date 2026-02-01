# PowerShell Script to stop all UAT infrastructure resources without terminating
# Run this script to stop EC2 and RDS resources

Write-Host "Stopping all UAT Infrastructure Resources..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# EC2 Instance IDs
$ec2Instances = @("i-0cd9b9ff2a96e8b95", "i-042a66c31a6166a1a")
$rdsInstanceId = "db-3KEG3QWU3YUFZN5HTQDSYAKPU4"
$region = "eu-west-1"

# Stop EC2 Instances
Write-Host ""
Write-Host "1. Stopping EC2 Instances..." -ForegroundColor Yellow
try {
    aws ec2 stop-instances --instance-ids $ec2Instances --region $region
    Write-Host "   ✓ EC2 instances stopped (tt-uat-app, tt-uat-jumper)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error stopping EC2 instances: $_" -ForegroundColor Red
}

# Stop RDS Instance
Write-Host ""
Write-Host "2. Stopping RDS Database..." -ForegroundColor Yellow
try {
    aws rds stop-db-instance --db-instance-identifier $rdsInstanceId --region $region
    Write-Host "   ✓ RDS instance stopped" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error stopping RDS: $_" -ForegroundColor Red
}

# EFS Status
Write-Host ""
Write-Host "3. EFS Status..." -ForegroundColor Yellow
Write-Host "   ℹ EFS filesystem is always available (cannot be stopped)" -ForegroundColor Cyan

# ALB Status
Write-Host ""
Write-Host "4. ALB Status..." -ForegroundColor Yellow
Write-Host "   ℹ ALB remains running (not stopped)" -ForegroundColor Cyan

# NAT Gateway Status
Write-Host ""
Write-Host "5. NAT Gateway Status..." -ForegroundColor Yellow
Write-Host "   ℹ NAT Gateway remains active (incurring charges)" -ForegroundColor Cyan

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✓ All EC2 and RDS resources have been stopped" -ForegroundColor Green
Write-Host "✓ Resources are NOT terminated - can be restarted anytime" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "To verify stopped resources:" -ForegroundColor Yellow
Write-Host "  aws ec2 describe-instances --instance-ids i-0cd9b9ff2a96e8b95 i-042a66c31a6166a1a --region eu-west-1" -ForegroundColor Gray
Write-Host "  aws rds describe-db-instances --db-instance-identifier $rdsInstanceId --region eu-west-1" -ForegroundColor Gray

Write-Host ""
Write-Host "To restart resources:" -ForegroundColor Yellow
Write-Host "  terraform apply -var-file=`"tfvars/uat.tfvars`" -auto-approve" -ForegroundColor Gray

Write-Host ""
Write-Host "Cost Optimization Tips:" -ForegroundColor Yellow
Write-Host "- Stopped EC2/RDS: No compute charges (storage still charges)" -ForegroundColor Gray
Write-Host "- NAT Gateway: $32/month (consider removing if not needed)" -ForegroundColor Gray
Write-Host "- ALB: $0.0252/hour (~$18.50/month)" -ForegroundColor Gray
Write-Host "- EFS: Based on storage used" -ForegroundColor Gray
