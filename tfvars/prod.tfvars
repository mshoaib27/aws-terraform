
account_id = "423623839339"
region     = "sa-east-1"
vpc_cidr = ["11.1.0.0/24"]
num_azs  = 4
ami_id   = "ami-1234567890abcdef0"
key_name = "sba-prod"
instances = [
  {
    name           = "sba-prod-app-01"
    instance_type  = "m5.xlarge"
    create_instance = true
    associate_public_ip_address = false
    ami_id   = "ami-1234567890abcdef0"
  },
  {
    name           = "sba-prod-app-02"
    instance_type  = "m5.xlarge"
    create_instance = true
    ami_id   = "ami-1234567890abcdef0"
    associate_public_ip_address = false
  },
  {
    name           = "instance-3"
    instance_type  = "t2.medium"
    create_instance = false
    ami_id   = "ami-1234567890abcdef0"
    associate_public_ip_address = false
  },
]

# RDS Configuration
clusters = [
  {
    name         = "sba-prod-db"
    create_cluster = true
    multi_az       = false
  },
]

# Tags
tags = {
  Environment = "dev"
}

# RDS Additional Configuration
enabled_cloudwatch_logs_exports = ["error", "general","audit","slowquery"]
master_username                 = "prod_master_user"

# KMS Configuration
kms_key_id  = "prod-kms-key-id"
kms_key_arn = "arn:aws:kms:us-west-2:739275445379:key/prod-kms-key-arn"
