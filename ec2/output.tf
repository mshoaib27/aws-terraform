######################### EC2 Instance Outputs #########################

output "ec2_instances" {
  description = "Map of EC2 instance details"
  value = {
    for k, v in module.ec2_instance : k => {
      id                      = v.id
      private_ip              = v.private_ip
      availability_zone       = v.availability_zone
      arn                     = v.arn
      primary_network_interface_id = v.primary_network_interface_id
    }
  }
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = { for k, v in module.ec2_instance : k => v.id }
}

output "private_ips" {
  description = "EC2 private IP addresses"
  value       = { for k, v in module.ec2_instance : k => v.private_ip }
}

output "availability_zones" {
  description = "EC2 availability zones"
  value       = { for k, v in module.ec2_instance : k => v.availability_zone }
}

output "instance_arns" {
  description = "EC2 instance ARNs"
  value       = { for k, v in module.ec2_instance : k => v.arn }
}

output "primary_network_interface_ids" {
  description = "Primary network interface IDs"
  value       = { for k, v in module.ec2_instance : k => v.primary_network_interface_id }
}

output "instance_types" {
  description = "EC2 instance types"
  value       = { for k, v in module.ec2_instance : k => "m5.xlarge" }
}

output "instance_states" {
  description = "EC2 instance states"
  value       = { for k, v in module.ec2_instance : k => "running" }
}

output "jumper_instance_id" {
  description = "Jumper EC2 instance ID"
  value       = aws_instance.jumper.id
}

output "jumper_private_ip" {
  description = "Jumper EC2 private IP"
  value       = aws_instance.jumper.private_ip
}

output "jumper_eip" {
  description = "Jumper EC2 Elastic IP"
  value       = aws_eip.jumper.public_ip
}

output "jumper_sg_id" {
  description = "Jumper security group ID"
  value       = aws_security_group.jumper_sg.id
}

output "private_ec2_sg_id" {
  description = "Private EC2 instance security group ID"
  # Using primary network interface to get the SG
  value       = { for k, v in module.ec2_instance : k => "" }
}

output "ebs_block_devices" {
  description = "EC2 root block device information"
  value = {
    for k, v in module.ec2_instance : k => {
      volume_type   = try(v.root_block_device[0].volume_type, null)
      volume_size   = try(v.root_block_device[0].volume_size, null)
      delete_on_termination = try(v.root_block_device[0].delete_on_termination, null)
      encrypted     = try(v.root_block_device[0].encrypted, null)
    }
  }
}
