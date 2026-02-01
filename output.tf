# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = var.vpc_cidr[0]
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_eips" {
  description = "NAT Gateway Elastic IPs"
  value       = module.vpc.nat_eips
}

output "instance_ids" {
  description = "All EC2 instance IDs (app, cron, api)"
  value       = module.ec2.instance_ids
}

output "app_server_ids" {
  description = "App server instance IDs"
  value       = module.ec2.app_server_ids
}

output "cron_server_ids" {
  description = "Cron server instance IDs"
  value       = module.ec2.cron_server_ids
}

output "api_server_ids" {
  description = "API server instance IDs"
  value       = module.ec2.api_server_ids
}

output "private_ips" {
  description = "EC2 private IPs (all servers)"
  value       = module.ec2.private_ips
}

output "jumper_instance_id" {
  description = "Jumper/bastion instance ID"
  value       = module.ec2.jumper_instance_id
}

output "jumper_private_ip" {
  description = "Jumper/bastion private IP"
  value       = module.ec2.jumper_private_ip
}

output "jumper_public_ip" {
  description = "Jumper/bastion public IP (Elastic IP)"
  value       = module.ec2.jumper_public_ip
}

output "jumper_sg_id" {
  description = "Jumper security group ID"
  value       = module.ec2.jumper_sg_id
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.rds_identifier
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = module.rds.rds_arn
}

# EFS Outputs
output "efs_id" {
  description = "EFS file system ID"
  value       = module.efs.efs_id
}

output "efs_dns_name" {
  description = "EFS DNS name for mounting"
  value       = module.efs.efs_dns_name
}

output "efs_arn" {
  description = "EFS ARN"
  value       = module.efs.efs_arn
}

# Security Group Outputs
output "rds_sg_id" {
  description = "RDS security group ID"
  value       = module.sg.sg_id
}

output "alb_sg_id" {
  description = "ALB security group ID"
  value       = module.sg.alb_sg_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_target_group_arn" {
  description = "ALB target group ARN"
  value       = module.alb.target_group_arn
}

