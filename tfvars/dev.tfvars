# Naming Convention Variables
customer_name = "tt"
environment   = "dev"

# Server Counts
app_server_count   = 1
cron_server_count  = 1
api_server_count   = 0

# Instance Types
app_server_instance_type    = "m5.large"
cron_server_instance_type   = "t3.medium"
api_server_instance_type    = "m5.xlarge"
jumper_server_instance_type = "t3.small"

# AWS Configuration
account_id = "739275445379"
region     = "sa-east-1"
num_azs    = 4
vpc_cidr   = ["11.1.0.0/24"]
ami_id     = "ami-1234567890abcdef0"
key_name   = "tt-dev"

# RDS Configuration
rds_instance_class       = "db.t3.small"
rds_allocated_storage    = 20
rds_engine_version       = "8.0.44"
rds_multi_az             = false
rds_storage_encrypted    = true
rds_storage_type         = "gp3"

master_username = "admin"
enabled_cloudwatch_logs_exports = ["error", "general"]

# KMS
kms_key_id  = "dev-kms-key-id"
kms_key_arn = "arn:aws:kms:us-west-2:739275445379:key/dev-kms-key-arn"

# Tags
tags = {
  Environment = "dev"
  Project     = "tt"
}

