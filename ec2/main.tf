
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "test-instance"
  instance_type = var.instance_type
  key_name               = "test"
  monitoring             = true
  create_eip             = true
  subnet_id           = var.private_subnets[0]
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  } 
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 10
    },
  ]
  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = false
    }
  ] 

  tags = {
    Name   = "shoaib"
    Environment = "dev"
  }
}