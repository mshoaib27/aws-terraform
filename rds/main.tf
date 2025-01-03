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
  instance_class          = "db.t3.medium"
  allocated_storage = 8
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  username         = var.master_username
  vpc_security_group_ids  = var.sg_id
  password         = random_password.master[each.key].result
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group[each.key].name
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  performance_insights_enabled = false
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports = ["audit","error","general","postgresql","slowquery","upgrade"]
  monitoring_interval     = "5"
  create_monitoring_role = true
  monitoring_role_name = "rdsmonitoring-role"
  parameters = [
    {
    name  = "innodb_buffer_pool_size"
    value = "128M"
    },{
    name = "connect_timeout"
    value = "30"
    },{
      name         = "innodb_lock_wait_timeout"
      value        = 300
      }, {
      name         = "log_output"
      value        = "FILE"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      }, {
      name         = "aurora_parallel_query"
      value        = "OFF"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      }, {
      name         = "require_secure_transport"
      value        = "ON"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      }
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