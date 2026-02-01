# Create app servers
module "ec2_app_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for name in var.app_server_names : name => name }

  name                        = each.value
  instance_type               = var.app_server_instance_type
  ami                         = "ami-03446a3af42c5e74e"
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = false
  create_eip                  = false
  iam_instance_profile        = var.iam_instance_profile
  
  root_block_device = {
    encrypted             = true
    volume_type           = "gp3"
    throughput            = 200
    volume_size           = 60
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  tags = merge(
    var.tags,
    {
      Name      = each.value
      owner     = "shoaib"
      Terraform = "true"
    }
  )
}

# Create cron servers
module "ec2_cron_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for name in var.cron_server_names : name => name }

  name                        = each.value
  instance_type               = var.cron_server_instance_type
  ami                         = "ami-03446a3af42c5e74e"
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = false
  create_eip                  = false
  iam_instance_profile        = var.iam_instance_profile
  
  root_block_device = {
    encrypted             = true
    volume_type           = "gp3"
    throughput            = 200
    volume_size           = 60
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  tags = merge(
    var.tags,
    {
      Name      = each.value
      owner     = "shoaib"
      Terraform = "true"
    }
  )
}

# Create API servers
module "ec2_api_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for name in var.api_server_names : name => name }

  name                        = each.value
  instance_type               = var.api_server_instance_type
  ami                         = "ami-03446a3af42c5e74e"
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = false
  create_eip                  = false
  iam_instance_profile        = var.iam_instance_profile
  
  root_block_device = {
    encrypted             = true
    volume_type           = "gp3"
    throughput            = 200
    volume_size           = 60
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  tags = merge(
    var.tags,
    {
      Name      = each.value
      owner     = "shoaib"
      Terraform = "true"
    }
  )
}

# Create jumper/bastion server (public)
resource "aws_instance" "jumper" {
  ami                         = "ami-03446a3af42c5e74e"
  instance_type               = var.jumper_server_instance_type
  subnet_id                   = var.public_subnets[0]
  key_name                    = var.key_name
  associate_public_ip_address = true
  monitoring                  = true
  iam_instance_profile        = var.iam_instance_profile
  vpc_security_group_ids      = [aws_security_group.jumper_sg.id]
  
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    throughput            = 200
    volume_size           = 60
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name      = var.jumper_name
      owner     = "shoaib"
      Terraform = "true"
    }
  )

  depends_on = [aws_security_group.jumper_sg]
}

resource "aws_eip" "jumper" {
  instance = aws_instance.jumper.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name      = "${var.jumper_name}-eip"
      owner     = "shoaib"
      Terraform = "true"
    }
  )

  depends_on = [aws_instance.jumper]
}

resource "aws_security_group" "jumper_sg" {
  name_prefix = "jumper-sg-"
  description = "Security group for jumper EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name      = "jumper-sg"
      owner     = "shoaib"
      Terraform = "true"
    }
  )
}


