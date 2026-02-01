# EC2 Instance Outputs

output "instance_ids" {
  description = "EC2 instance IDs - combined app, cron, and API servers"
  value = merge(
    { for k, v in module.ec2_app_servers : k => v.id },
    { for k, v in module.ec2_cron_servers : k => v.id },
    { for k, v in module.ec2_api_servers : k => v.id }
  )
}

output "app_server_ids" {
  description = "App server instance IDs"
  value       = { for k, v in module.ec2_app_servers : k => v.id }
}

output "cron_server_ids" {
  description = "Cron server instance IDs"
  value       = { for k, v in module.ec2_cron_servers : k => v.id }
}

output "api_server_ids" {
  description = "API server instance IDs"
  value       = { for k, v in module.ec2_api_servers : k => v.id }
}

output "private_ips" {
  description = "EC2 private IP addresses - combined all servers"
  value = merge(
    { for k, v in module.ec2_app_servers : k => v.private_ip },
    { for k, v in module.ec2_cron_servers : k => v.private_ip },
    { for k, v in module.ec2_api_servers : k => v.private_ip }
  )
}

output "app_server_private_ips" {
  description = "App server private IP addresses"
  value       = { for k, v in module.ec2_app_servers : k => v.private_ip }
}

output "cron_server_private_ips" {
  description = "Cron server private IP addresses"
  value       = { for k, v in module.ec2_cron_servers : k => v.private_ip }
}

output "api_server_private_ips" {
  description = "API server private IP addresses"
  value       = { for k, v in module.ec2_api_servers : k => v.private_ip }
}

output "availability_zones" {
  description = "EC2 availability zones - combined all servers"
  value = merge(
    { for k, v in module.ec2_app_servers : k => v.availability_zone },
    { for k, v in module.ec2_cron_servers : k => v.availability_zone },
    { for k, v in module.ec2_api_servers : k => v.availability_zone }
  )
}

output "instance_arns" {
  description = "EC2 instance ARNs - combined all servers"
  value = merge(
    { for k, v in module.ec2_app_servers : k => v.arn },
    { for k, v in module.ec2_cron_servers : k => v.arn },
    { for k, v in module.ec2_api_servers : k => v.arn }
  )
}

# Jumper outputs
output "jumper_instance_id" {
  description = "Jumper/bastion EC2 instance ID"
  value       = aws_instance.jumper.id
}

output "jumper_private_ip" {
  description = "Jumper/bastion private IP"
  value       = aws_instance.jumper.private_ip
}

output "jumper_public_ip" {
  description = "Jumper/bastion elastic public IP"
  value       = aws_eip.jumper.public_ip
}

output "jumper_eip_id" {
  description = "Jumper elastic IP ID"
  value       = aws_eip.jumper.id
}

output "jumper_sg_id" {
  description = "Jumper security group ID"
  value       = aws_security_group.jumper_sg.id
}
