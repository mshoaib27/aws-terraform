locals {
  clusters          = var.clusters
  region            = var.region
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  for_each    = { for cluster in local.clusters : cluster.name => cluster }
  name        = each.value.name
  description = "Subnet group for the RDS MySQL cluster"
  subnet_ids  = var.private_subnets
}

module "rds_mysql" {
  source                  = "terraform-aws-modules/rds/aws"
  for_each                = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  identifier = each.value.name
  engine = "mysql"
  engine_version = "8.0"
  major_engine_version = "8.0"
  family = "mysql8.0"
  instance_class          = "db.m6g.2xlarge"
  allocated_storage = 8
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  username         = var.master_username
  vpc_security_group_ids  = var.sg_id
  password         = random_password.master[each.key].result
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group[each.key].name
  parameter_group_name    = aws_db_parameter_group.rds_parameter_group[each.key].name
  #replicate_source_db = module.rds_mysql.db_instance_identifier
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  performance_insights_enabled = false
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports = ["audit","error","general","slowquery"]
  monitoring_interval     = "5"
  create_monitoring_role = true
  monitoring_role_name = "rdsmonitoring-role"
  parameters = [
    {
      name  = "connect_timeout"
      value = "30"
    },
  ]

  tags = merge(
    var.tags,
    {
      Name       = each.value.name,
      RDS-Instance = each.value.name
    }
  )
}

# Supporting Resources
resource "random_password" "master" {
  for_each = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  length  = 20
  special = false
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  for_each = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  name     = "${each.value.name}-param-group"
  family   = "mysql8.0"
  description = "Custom parameter group for MySQL 8.0"
}

  