module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for instance in var.instances : instance.name => instance if instance.create_instance }

  name                      = each.value.name
  instance_type             = each.value.instance_type
  key_name                  = var.key_name
  monitoring                = true
  subnet_id                 = var.private_subnets[0]
  ami                       = each.value.ami_id
  associate_public_ip_address = each.value.associate_public_ip_address

  create_eip = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 60
    },
  ]
}