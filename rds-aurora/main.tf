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

module "aurora_mysql" {
  source                  = "terraform-aws-modules/rds-aurora/aws"
  for_each                = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  name = each.value.name
  engine                  = "aurora-mysql"
  instance_class          = "db.t3.medium"
  instances = {
    instance-1 = {
      instance_class = "db.t3.medium"
      identifier     = "instance-1"
    }
    instance-2 = {
      instance_class = "db.t3.medium"
      identifier     = "instance-2"
    }
  }
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  master_username         = var.master_username
  vpc_id                  = var.vpc_id
  vpc_security_group_ids  = var.sg_id
  master_password         = random_password.master[each.key].result
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group[each.key].name
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  performance_insights_enabled = false
  db_cluster_parameter_group_parameters = [
    {
    name  = "innodb_buffer_pool_size"
    value = "128M"
    apply_method = "immmediate"
    },{
    name = "connect_timeout"
    value = "30"
    },{
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "aurora_parallel_query"
      value        = "OFF"
      apply_method = "pending-reboot"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
      }
  ]
  iam_database_authentication_enabled = true
  monitoring_interval     = "5"
  create_monitoring_role = true

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


