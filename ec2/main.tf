module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  for_each = { for instance in var.instances : instance.name => instance if instance.create_instance }

  name                        = each.value.name
  instance_type               = each.value.instance_type
  ami                         = each.value.ami_id
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = each.value.associate_public_ip_address
  create_eip = false
  iam_instance_profile        = var.iam_instance_profile
  root_block_device = {
    encrypted   = true
    volume_type = "gp3"
    throughput  = 200
    volume_size = 60
  }

  # User data for installing Apache, PHP 7.4 and EFS mount
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  tags = merge(
    var.tags,
    {
      Name      = each.value.name
      owner     = "shoaib"
      Terraform = "true"
    }
  )
}

######################### Jumper EC2 Instance (Public) #########################
resource "aws_instance" "jumper" {
  ami                    = "ami-03446a3af42c5e74e"  # Same AMI as private instance
  instance_type          = "t3.small"
  subnet_id              = var.public_subnets[0]
  key_name               = var.key_name
  associate_public_ip_address = true
  monitoring             = true
  iam_instance_profile   = var.iam_instance_profile
  
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    throughput  = 200
    volume_size = 60
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.jumper_sg.id]

  tags = {
    Name      = "tt-uat-jumper"
    owner     = "shoaib"
    Terraform = "true"
  }

  depends_on = [var.public_subnets]
}

resource "aws_eip" "jumper" {
  instance = aws_instance.jumper.id
  domain   = "vpc"

  tags = {
    Name      = "tt-uat-jumper-eip"
    owner     = "shoaib"
    Terraform = "true"
  }

  depends_on = [aws_instance.jumper]
}

######################### Jumper Security Group #########################
resource "aws_security_group" "jumper_sg" {
  name        = "jumper-sg"
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

  tags = {
    Name      = "jumper-sg"
    owner     = "shoaib"
    Terraform = "true"
  }
}


