output "vpc_id" {
  description = "VPC ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_eip" {
  description = "Elastic IP allocated for the NAT Gateway"
  value       = aws_eip.nat.*.public_ip
}