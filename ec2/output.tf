 /* output "ec2_instances" {
  description = "List of EC2 instance IDs"
  value = { for k, instance in module.ec2_instances : k => instance.id }
} */

/* output "ec2_public_ips" {
  description = "List of EC2 public IPs"
  value = { for k, instance in module.ec2_instances : k => instance.public_ip }
} */

/* output "ec2_private_ips" {
  description = "List of EC2 private IPs"
  value = { for k, instance in module.ec2_instances : k => instance.private_ip }
} */