######################### Security Group Outputs #########################

output "sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "sg_arn" {
  description = "RDS security group ARN"
  value       = aws_security_group.rds_sg.arn
}

output "sg_name" {
  description = "RDS security group name"
  value       = aws_security_group.rds_sg.name
}

output "sg_description" {
  description = "RDS security group description"
  value       = aws_security_group.rds_sg.description
}

output "sg_vpc_id" {
  description = "VPC ID associated with the security group"
  value       = aws_security_group.rds_sg.vpc_id
}

output "sg_owner_id" {
  description = "AWS account ID (owner) of the security group"
  value       = aws_security_group.rds_sg.owner_id
}

output "sg_ingress_rules" {
  description = "Ingress rules count"
  value       = length(aws_security_group.rds_sg.ingress)
}

output "sg_egress_rules" {
  description = "Egress rules count"
  value       = length(aws_security_group.rds_sg.egress)
}

output "sg_tags" {
  description = "Tags associated with the security group"
  value       = aws_security_group.rds_sg.tags
}

output "sg_complete_details" {
  description = "Complete security group details"
  value = {
    id          = aws_security_group.rds_sg.id
    arn         = aws_security_group.rds_sg.arn
    name        = aws_security_group.rds_sg.name
    vpc_id      = aws_security_group.rds_sg.vpc_id
    description = aws_security_group.rds_sg.description
    tags        = aws_security_group.rds_sg.tags
  }
}

######################### EC2 Security Group Outputs #########################

output "ec2_sg_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_sg_arn" {
  description = "EC2 security group ARN"
  value       = aws_security_group.ec2_sg.arn
}

output "ec2_sg_name" {
  description = "EC2 security group name"
  value       = aws_security_group.ec2_sg.name
}

output "ec2_sg_description" {
  description = "EC2 security group description"
  value       = aws_security_group.ec2_sg.description
}

output "ec2_sg_vpc_id" {
  description = "VPC ID associated with EC2 security group"
  value       = aws_security_group.ec2_sg.vpc_id
}

output "ec2_sg_ingress_rules" {
  description = "Ingress rules for EC2 security group"
  value = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
    }
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access"
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access"
    }
  }
}

output "ec2_sg_egress_rules" {
  description = "Egress rules for EC2 security group"
  value = {
    all_traffic = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
    }
  }
}

output "ec2_sg_complete_details" {
  description = "Complete EC2 security group details"
  value = {
    id          = aws_security_group.ec2_sg.id
    arn         = aws_security_group.ec2_sg.arn
    name        = aws_security_group.ec2_sg.name
    vpc_id      = aws_security_group.ec2_sg.vpc_id
    description = aws_security_group.ec2_sg.description
    tags        = aws_security_group.ec2_sg.tags
  }
}

output "alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "alb_sg_arn" {
  description = "ALB security group ARN"
  value       = aws_security_group.alb_sg.arn
}

output "alb_sg_complete_details" {
  description = "Complete ALB security group details"
  value = {
    id          = aws_security_group.alb_sg.id
    arn         = aws_security_group.alb_sg.arn
    name        = aws_security_group.alb_sg.name
    vpc_id      = aws_security_group.alb_sg.vpc_id
    description = aws_security_group.alb_sg.description
    tags        = aws_security_group.alb_sg.tags
  }
}
