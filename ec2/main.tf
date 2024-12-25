locals {
  # Convert instances to a map for easy access in the for_each loop
  instance_map = { for instance in var.instances : instance.name => instance if instance.create_instance }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = local.instance_map

  name        = each.key
  instance_type = each.value.instance_type
  ami          = var.ami_id
  key_name     = var.key_name
  monitoring   = true
  enable_volume_tags = true

  # Use lookup function to dynamically assign subnet based on availability zone
  subnet_id = lookup(var.subnets, each.value.availability_zone)

  tags = {
    Name = each.key
  }
  depends_on = [module.vpc]

  # Optionally enable public IP if you want instances to have a public IP
  associate_public_ip_address = each.value.associate_public_ip_address
}