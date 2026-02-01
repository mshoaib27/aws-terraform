# Naming Convention Variables
customer_name = "sba"
environment   = "prod"

# Server Counts
app_server_count   = 2
cron_server_count  = 1
api_server_count   = 1

# Instance Types
app_server_instance_type    = "m5.xlarge"
cron_server_instance_type   = "m5.xlarge"
api_server_instance_type    = "m5.xlarge"
jumper_server_instance_type = "t3.micro"

# AWS Configuration
account_id = "423623839339"
region     = "sa-east-1"
vpc_cidr   = ["11.1.0.0/24"]
num_azs    = 4
ami_id     = "ami-0dccf463b6ff559ff"
key_name   = "sba-prod"

# RDS Configuration
rds_instance_class       = "db.m5.large"
rds_allocated_storage    = 100
rds_engine_version       = "8.0.44"
rds_multi_az             = true
rds_storage_encrypted    = true
rds_storage_type         = "gp3"

master_username = "admin"
enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

# Tags
tags = {
  Environment = "prod"
  Project     = "sba"
}
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


redis_cluster_id = "prod-cluster"
node_type        = "cache.r6g.12xlarge"
allowed_cidr_blocks = ["11.1.0.0/16"]
num_cache_nodes  = 1



create_alb              = true
alb_name                = "Production-APP-LB"
internal                = false
enable_deletion_protection = false

