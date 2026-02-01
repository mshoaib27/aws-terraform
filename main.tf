module "vpc" {
  source   = "./vpc"
  region   = var.region
  vpc_cidr = var.vpc_cidr
  num_azs  = var.num_azs
}

module "iam" {
  source = "./iam"
  region = var.region
  tags   = var.tags
}

module "ec2" {
  source                      = "./ec2"
  app_server_names            = local.app_server_names
  cron_server_names           = local.cron_server_names
  api_server_names            = local.api_server_names
  jumper_name                 = local.jumper_name
  app_server_instance_type    = var.app_server_instance_type
  cron_server_instance_type   = var.cron_server_instance_type
  api_server_instance_type    = var.api_server_instance_type
  jumper_server_instance_type = var.jumper_server_instance_type
  region                      = var.region
  key_name                    = var.key_name
  private_subnets             = module.vpc.private_subnets
  public_subnets              = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
  efs_dns_name                = module.efs.efs_dns_name
  iam_instance_profile        = module.iam.ec2_ssm_profile_id
  tags                        = var.tags
  depends_on                  = [module.efs, module.iam]
}

module "rds" {
  source          = "./rds"
  region          = var.region
  private_subnets = module.vpc.private_subnets
  master_username = var.master_username
  master_password = var.master_password
  sg_id           = [module.sg.sg_id]
  kms_key_id      = var.kms_key_id
  tags            = var.tags

  rds_instance_name              = local.rds_instance_name
  rds_instance_class             = var.rds_instance_class
  rds_allocated_storage          = var.rds_allocated_storage
  rds_storage_type               = var.rds_storage_type
  rds_storage_encrypted          = var.rds_storage_encrypted
  rds_backup_retention           = var.rds_backup_retention
  rds_multi_az                   = var.rds_multi_az
  rds_deletion_protection        = var.rds_deletion_protection
  rds_engine                     = var.rds_engine
  rds_engine_version             = var.rds_engine_version
  rds_parameter_family           = var.rds_parameter_family
  rds_monitoring_interval        = var.rds_monitoring_interval
  rds_enable_cloudwatch_logs_exports = var.rds_enable_cloudwatch_logs_exports
  rds_apply_immediately          = var.rds_apply_immediately
  rds_copy_tags_to_snapshot      = var.rds_copy_tags_to_snapshot
  rds_publicly_accessible        = var.rds_publicly_accessible
}

module "efs" {
  source           = "./efs"
  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = var.vpc_cidr
  private_subnets = module.vpc.private_subnets
  region           = var.region
  tags             = var.tags
}

module "sg" {
  source             = "./sg"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  jumper_sg_id       = module.ec2.jumper_sg_id
  private_ec2_sg_id  = ""
  efs_sg_id          = module.efs.efs_security_group_id
  tags               = var.tags
  depends_on         = [module.ec2, module.efs]
}

module "alb" {
  source                     = "./alb"
  create_alb                 = var.create_alb
  alb_name                   = local.alb_name
  internal                   = var.internal
  security_groups            = [module.sg.alb_sg_id]
  vpc_id                     = module.vpc.vpc_id
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
  public_subnets             = module.vpc.public_subnets
  register_targets           = true
  target_instance_id         = values(module.ec2.instance_ids)[0]
  ssl_certificate_arn        = var.certificate_arn
}
