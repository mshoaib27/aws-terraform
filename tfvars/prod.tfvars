
account_id = "423623839339"
region     = "sa-east-1"
vpc_cidr = ["11.1.0.0/24"]
num_azs  = 4
ami_id   = "ami-028915287c920263d"

key_name = "sba-prod"
instances = [
  {
    name                        = "prod-app-01"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-079a9eba298521f24"
    associate_public_ip_address = false
    create_instance             = true
  },
  {
    name                        = "prod-app-02"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-079a9eba298521f24"
    associate_public_ip_address = false
    create_instance             = true
  },
  {
    name                        = "prod-api-01"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-079a9eba298521f24"
    associate_public_ip_address = false
    create_instance             = true
  },
  {
    name                        = "prod-cron-01"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-079a9eba298521f24"
    associate_public_ip_address = false
    create_instance             = true
  },
]

# RDS Configuration

master_username = "sbamaster"
clusters = [
  {
    name            = "sba-prod-db"
    create_instance = true
  }
]


# Tags
tags = {
  Environment = "prod"
}

# RDS Additional Configuration
enabled_cloudwatch_logs_exports = ["error", "general","audit","slowquery"]

# KMS Configuration
kms_key_id  = "prod-kms-key-id"
kms_key_arn = "arn:aws:kms:us-west-2:739275445379:key/prod-kms-key-arn"


redis_cluster_id = "my-redis-cluster"
node_type        = "cache.t3.micro"
allowed_cidr_blocks = ["11.1.0.0/16"]
num_cache_nodes  = 1


create_alb              = true
alb_name                = "Production-APP-LB"
internal                = false
enable_deletion_protection = false

