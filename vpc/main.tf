module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "pipeline-vpc"
  cidr = var.vpc_cidr[0]
  azs             = slice(data.aws_availability_zones.available.names, 0, min(var.num_azs, length(data.aws_availability_zones.available.names)))
  public_subnets  = [for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr[0], 3, i * 2)]
  private_subnets = [for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr[0], 3, i * 2 + 1)]

  # DNS Parameters in VPC 
  enable_dns_hostnames = true
  enable_dns_support   = true
}



data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "region-name"
    values = [var.region]
  }
}


