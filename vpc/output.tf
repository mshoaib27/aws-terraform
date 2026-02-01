######################### VPC Outputs #########################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = var.vpc_cidr[0]
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${module.vpc.vpc_id}"
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_arns" {
  description = "Public subnet ARNs"
  value       = [for subnet_id in module.vpc.public_subnets : "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${subnet_id}"]
}

output "private_subnet_arns" {
  description = "Private subnet ARNs"
  value       = [for subnet_id in module.vpc.private_subnets : "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${subnet_id}"]
}

output "nat_eips" {
  description = "NAT Gateway Elastic IPs"
  value       = aws_eip.nat.*.public_ip
}

output "nat_eip_allocation_ids" {
  description = "NAT Gateway EIP allocation IDs"
  value       = aws_eip.nat.*.id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = data.aws_availability_zones.available.names
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = try(module.vpc.igw_id, null)
}

output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = try(module.vpc.public_route_table_ids, [])
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = try(module.vpc.private_route_table_ids, [])
}

output "vpc_details" {
  description = "VPC complete details"
  value = {
    vpc_id            = module.vpc.vpc_id
    cidr_block        = module.vpc.vpc_cidr_block
    enable_dns_support = try(module.vpc.vpc_enable_dns_support, null)
    enable_dns_hostnames = try(module.vpc.vpc_enable_dns_hostnames, null)
    instance_tenancy  = try(module.vpc.vpc_instance_tenancy, null)
    public_subnets   = module.vpc.public_subnets
    private_subnets  = module.vpc.private_subnets
  }
}

output "nat_gateway_count" {
  description = "Number of NAT Gateways"
  value       = length(aws_eip.nat)
}


