output "ec2_instances" {
  description = "List of EC2 instance IDs"
  value = { for k, instance in module.ec2_instances : k => instance.id }
}

output "ec2_public_ips" {
  description = "List of EC2 public IPs"
  value = { for k, instance in module.ec2_instances : k => instance.public_ip }
}

output "subnet_ids" {
  value = { for az in local.instance_map : az => lookup(var.subnets, local.instance_map[az].availability_zone) }
}
