module "vpc" {
  source     = "./vpc"
  region     = var.region
  vpc_cidr   = var.vpc_cidr
  num_azs    = var.num_azs
}

/* module "ec2" {
  source    = "./ec2"
  region    = var.region
  instances = var.instances
  key_name  = var.key_name
  ami_id    = var.ami_id
  subnets   = module.vpc.private_subnets
  depends_on = [module.vpc]
} */

module "S3" {
  source = "./s3"
}