module "vpc" {
  source     = "./vpc"
  region     = var.region
  vpc_cidr   = var.vpc_cidr
  num_azs    = var.num_azs
}

/*  module "ec2" {
  source    = "./ec2"
  region    = var.region
  key_name  = var.key_name
  ami_id    = var.ami_id
  private_subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  instance_type = var.instance_type
  name = var.name
} */

/* module "S3" {
  source = "./s3"
}
 */
/*    module "rds_mysql" {
  source              = "./rds-aurora"
  clusters            = var.clusters
  region              = var.region
  vpc_id              = module.vpc.vpc_id          
  private_subnets     = module.vpc.private_subnets
  master_username     = var.master_username
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                = var.tags
  sg_id =  [module.sg.sg_id]
}  */

/*   module "rds" {
  source = "./rds"
  clusters = var.clusters
  region = var.region
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  master_username = var.master_username
  sg_id = [module.sg.sg_id]
} */

/* module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
  tags = var.tags
} */

/* module "kms"{
  source = "./kms"
} */

/* module "efs" {
  source = "./efs"
  region = var.region
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
} */