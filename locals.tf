######################### Naming Convention Locals #########################
# This file defines all naming conventions for resources
# Format: {customer_name}-{environment}-{resource_type}-{index/suffix}
# Examples:
#   - App servers: tt-uat-app-01, tt-uat-app-02
#   - Cron servers: tt-uat-cron-01
#   - API servers: tt-uat-api-01, tt-uat-api-02
#   - RDS: tt-uat-db
#   - EFS: tt-uat-efs
#   - ALB: tt-uat-alb
#   - VPC: tt-uat-vpc

locals {
  # Base naming
  name_prefix = "${var.customer_name}-${var.environment}"

  # EC2 Instance Names
  app_server_names = [for i in range(var.app_server_count) : "${local.name_prefix}-app-${format("%02d", i + 1)}"]
  cron_server_names = [for i in range(var.cron_server_count) : "${local.name_prefix}-cron-${format("%02d", i + 1)}"]
  api_server_names = [for i in range(var.api_server_count) : "${local.name_prefix}-api-${format("%02d", i + 1)}"]
  jumper_name = "${local.name_prefix}-jumper"

  # Database Names
  rds_instance_name = "${local.name_prefix}-db"
  rds_subnet_group_name = "${local.name_prefix}-db-subnet-group"
  rds_parameter_group_name = "${local.name_prefix}-params"
  rds_option_group_name = "${local.name_prefix}-options"

  # Storage Names
  efs_name = "${local.name_prefix}-efs"
  efs_mount_target_name = "${local.name_prefix}-efs-mount"
  
  # Load Balancer Names
  alb_name = "${local.name_prefix}-alb"
  alb_target_group_name = "${local.name_prefix}-alb-tg"

  # Network Names
  vpc_name = "${local.name_prefix}-vpc"
  nat_gateway_name = "${local.name_prefix}-nat"
  internet_gateway_name = "${local.name_prefix}-igw"

  # Security Group Names
  rds_sg_name = "${local.name_prefix}-rds-sg"
  ec2_sg_name = "${local.name_prefix}-ec2-sg"
  alb_sg_name = "${local.name_prefix}-alb-sg"
  jumper_sg_name = "${local.name_prefix}-jumper-sg"
  efs_sg_name = "${local.name_prefix}-efs-sg"

  # IAM Names
  ec2_ssm_role_name = "${local.name_prefix}-ec2-ssm-role"
  ec2_ssm_profile_name = "${local.name_prefix}-ec2-ssm-profile"

  # Default Tags
  common_tags = {
    Customer    = var.customer_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }

  # Server configuration maps
  all_servers = merge(
    { for name in local.app_server_names : name => { type = "app", instance_type = var.app_server_instance_type, role = "application" } },
    { for name in local.cron_server_names : name => { type = "cron", instance_type = var.cron_server_instance_type, role = "scheduler" } },
    { for name in local.api_server_names : name => { type = "api", instance_type = var.api_server_instance_type, role = "api" } }
  )
}
