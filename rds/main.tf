locals {
  clusters          = var.clusters
  region            = var.region
  parameter_family  = "aurora-postgresql14" # Adjust based on Aurora version
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.9"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "aurora_db_subnet_group" {
  for_each    = { for cluster in local.clusters : cluster.name => cluster }
  name        = each.value.name
  description = "Subnet group for the Aurora PostgreSQL cluster"
  subnet_ids  = var.subnet_ids
  #depends_on  = [module.vpc]
}

module "aurora_postgresql_v2" {
  for_each                   = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  source                     = "terraform-aws-modules/rds-aurora/aws"
  name                       = each.value.name
  engine                     = data.aws_rds_engine_version.postgresql.engine
  engine_mode                = "provisioned"
  engine_version             = data.aws_rds_engine_version.postgresql.version
  storage_encrypted          = true
  kms_key_id                 = var.kms_key_id
  master_username            = var.master_username
  master_password            = random_password.master[each.key].result
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.custom_cluster_pg.name
  db_parameter_group_name    = aws_db_parameter_group.custom_instance_pg.name
  create_security_group      = false
  performance_insights_enabled = true
  deletion_protection        = true
  backup_retention_period    = 14
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  auto_minor_version_upgrade = false
  vpc_id                     = var.vpc_id
  db_subnet_group_name       = aws_db_subnet_group.aurora_db_subnet_group[each.key].name
  monitoring_interval        = 60
  apply_immediately          = true
  skip_final_snapshot        = true
  instance_class             = "db.serverless"
  storage_type               = "aurora-iopt1"

  serverlessv2_scaling_configuration =  {
    min_capacity = each.value.min_capacity
    max_capacity = each.value.max_capacity
  }

  instances = {
    instance-1 = {
      instance_class = "db.serverless"
      priority       = 0
      promotion_tier = 0
    }
    instance-2 = {
      instance_class = "db.serverless"
      priority       = 1
      promotion_tier = 1
    }
  }
  iam_database_authentication_enabled = true
  vpc_security_group_ids = var.sg_id
  tags = merge(
    var.tags,
    {
      Name       = each.value.name,
      //RDS-Role   = each.key == "writer" ? "writer" : "reader",
      RDS-Cluster = each.value.name
    }
  )
}

# Supporting Resources
resource "random_password" "master" {
  for_each = { for cluster in local.clusters : cluster.name => cluster if cluster.create_cluster }
  length  = 20
  special = false
}
resource "aws_rds_cluster_parameter_group" "custom_cluster_pg" {
  name        = "clients-cluster-pg"
  family      = local.parameter_family
  description = "Custom cluster parameter group"
  parameter {
    name  = "temp_buffers"
    value = "262144"
  }
  parameter {
    name  = "work_mem"
    value = "131072"
  }
}
resource "aws_db_parameter_group" "custom_instance_pg" {
  name        = "clients-instance-pg"
  family      = local.parameter_family
  description = "Custom instance parameter group"
  parameter {
    name  = "temp_buffers"
    value = "262144"
  }
  parameter {
    name  = "work_mem"
    value = "131072"
  }
}
# resource "null_resource" "write_endpoints" {
#   for_each = module.aurora_postgresql_v2
#   provisioner "local-exec" {
#     command = "chmod +x ${path.module}/write_endpoints.sh && ${path.module}/write_endpoints.sh ${each.value.cluster_id} ${var.region} ${each.key} ${path.module}"
#   }
#   depends_on = [module.aurora_postgresql_v2]
# }