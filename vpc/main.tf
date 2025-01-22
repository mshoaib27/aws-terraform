module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sba-prod-vpc"
  cidr = var.vpc_cidr[0]
  #azs            = data.aws_availability_zones.available.names
  azs             = slice(data.aws_availability_zones.available.names, 0, min(var.num_azs, length(data.aws_availability_zones.available.names)))
  public_subnets  = [for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr[0], 3, i * 2)]
  private_subnets = [for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr[0], 3, i * 2 + 1)]

  # DNS Parameters in VPC 
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT Gateways - Outbound Communication from Private Subnets to the Internet
  single_nat_gateway  = false
  enable_nat_gateway  = false
  reuse_nat_ips       = false
  external_nat_ip_ids = aws_eip.nat.*.id
  flow_log_file_format = "parquet"
}

resource "aws_eip" "nat" {
  count = 1
  depends_on = [ data.aws_availability_zones.available ]
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