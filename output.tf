######################### VPC Outputs #########################
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

######################### EC2 Outputs #########################
output "ec2_instances" {
  description = "EC2 instance details"
  value       = module.ec2.ec2_instances
}

output "ec2_instance_ids" {
  description = "EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "EC2 private IP addresses"
  value       = module.ec2.private_ips
}

######################### RDS Outputs #########################
output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = module.rds.rds_identifier
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "rds_instance_resource_id" {
  description = "RDS resource ID"
  value       = module.rds.rds_resource_id
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds.rds_arn
}

######################### Security Group Outputs #########################
output "rds_sg_id" {
  description = "RDS security group ID"
  value       = module.sg.sg_id
}

output "rds_sg_arn" {
  description = "RDS security group ARN"
  value       = module.sg.sg_arn
}

