data "aws_caller_identity" "current" {}

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

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr[0]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name          = "tt-uat-vpc"
    created-by    = "shoaib"
    Terraform     = "true"
    Environment   = "uat"
  }
}

resource "aws_subnet" "public" {
  count                   = var.num_azs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr[0], 3, count.index * 2)
  availability_zone       = slice(data.aws_availability_zones.available.names, 0, min(var.num_azs, length(data.aws_availability_zones.available.names)))[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name      = "tt-uat-public-subnet-${count.index + 1}"
    Type      = "Public"
    Terraform = "true"
  }
}

resource "aws_subnet" "private" {
  count             = var.num_azs
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr[0], 3, count.index * 2 + 1)
  availability_zone = slice(data.aws_availability_zones.available.names, 0, min(var.num_azs, length(data.aws_availability_zones.available.names)))[count.index]

  tags = {
    Name      = "tt-uat-private-subnet-${count.index + 1}"
    Type      = "Private"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "tt-uat-igw"
    Terraform = "true"
  }
}

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name      = "tt-uat-nat-eip"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name      = "tt-uat-nat"
    Terraform = "true"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "tt-uat-public-rt"
    Type      = "Public"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.num_azs
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name      = "tt-uat-private-rt"
    Type      = "Private"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.num_azs
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
