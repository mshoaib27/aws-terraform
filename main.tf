module "vpc" {
  source     = "./vpc"
  region     = var.region
  vpc_cidr   = var.vpc_cidr
  num_azs    = var.num_azs
}

module "ec2" {
  source           = "./ec2"
  instances        = var.instances
  region           = var.region
  key_name         = var.key_name
  private_subnets  = module.vpc.private_subnets
}


module "S3" {
  source = "./s3"
}

/* module "rds_mysql" {
  source              = "./rds-aurora"
  clusters            = var.clusters
  region              = var.region
  vpc_id              = module.vpc.vpc_id          
  private_subnets     = module.vpc.private_subnets
  master_username     = var.master_username
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                = var.tags
  sg_id               =  [module.sg.sg_id]
} */

module "rds" {
  source          = "./rds"
  clusters = var.clusters
  region          = var.region
  private_subnets = module.vpc.private_subnets
  master_username = var.master_username
  sg_id           = [module.sg.sg_id]
  kms_key_id = var.kms_key_id
  tags = var.tags 
}

module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
  tags = var.tags
}

module "kms"{
  source = "./kms"
}

/* module "efs" {
  source = "./efs"
  region = var.region
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
} */

module "redis" {
  source          = "./redis"
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  allowed_cidr_blocks = var.allowed_cidr_blocks
  redis_cluster_id    = var.redis_cluster_id
  node_type           = var.node_type
  num_cache_nodes     = var.num_cache_nodes
  tags                = var.tags
}

module "alb" {
  source                  = "./alb"
  create_alb              = var.create_alb
  alb_name                = var.alb_name
  internal                = var.internal
  security_groups         = [module.sg.sg_id]
  subnets                 = module.vpc.public_subnets
  vpc_id                  = module.vpc.vpc_id
  enable_deletion_protection = var.enable_deletion_protection
  tags                    = var.tags
}
