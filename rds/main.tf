locals {
  clusters          = var.clusters
  region            = var.region
  parameter_family  = "mysql8.0"
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  for_each    = { for cluster in local.clusters : cluster.name => cluster }
  name        = each.value.name
  description = "Subnet group for the RDS MySQL cluster"
  subnet_ids  = var.private_subnets
}

module "rds_mysql" {
  for_each                = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  source                  = "terraform-aws-modules/rds-aurora/aws"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3"
  instance_class          = "db.t3.medium"
  instances = {
    one = {}
    2 = {
      instance_class = "db.t3.medium"
    }
  }
  allocated_storage       = 20 
  storage_type            = "gp2"
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  master_username         = var.master_username
  master_password         = random_password.master[each.key].result
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group[each.key].name
  vpc_security_group_ids  = var.sg_id
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = true
  backup_retention_period = 7
  performance_insights_enabled = true
  monitoring_interval     = 0
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
resource "aws_db_parameter_group" "custom_instance_pg" {
  name        = "clients-instance-pg"
  family      = local.parameter_family
  description = "Custom instance parameter group for MySQL"
  parameter {
    name  = "max_connections"
    value = "150"
  }
  parameter {
    name  = "innodb_buffer_pool_size"
    value = "134217728"
  }
}