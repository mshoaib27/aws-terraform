locals {
  clusters = var.clusters
  region   = var.region
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "rds_db_subnet_group" {
  for_each    = { for cluster in local.clusters : cluster.name => cluster }
  name        = each.value.name
  description = "Subnet group for the RDS MySQL instance"
  subnet_ids  = var.private_subnets
}

# Create Standalone RDS MySQL Instances
module "rds_mysql" {
  source                  = "terraform-aws-modules/rds/aws"
  for_each                = { for cluster in local.clusters : cluster.name => cluster if cluster.create_instance }
  identifier              = each.value.name
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.m6g.2xlarge"
  allocated_storage       = 500
  storage_encrypted       = true
  username                = var.master_username
  password                = random_password.master[each.key].result
  vpc_security_group_ids  = var.sg_id
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group[each.key].name
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  monitoring_interval     = 5
  create_monitoring_role  = true
  monitoring_role_name    = "rds-monitoring-role"
  major_engine_version = "8.0"
  family = "mysql8.0"

  parameters = [
    {
      name  = "connect_timeout"
      value = "30"
    },
  ]

  tags = merge(
    var.tags,
    {
      Name = each.value.name,
    }
  )
}

# Generate Random Passwords
resource "random_password" "master" {
  for_each = { for cluster in local.clusters : cluster.name => cluster if cluster.create_instance }
  length   = 20
  special  = false
}
