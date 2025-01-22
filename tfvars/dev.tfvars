account_id      = "739275445379"
region        = "sa-east-1"
num_azs       = 4

vpc_cidr      = ["11.1.0.0/24"]

ami_id        = "ami-1234567890abcdef0"
key_name      = "dev-keypair"
instances = [
  { name = "dev-app-server", create_instance = true, instance_type = "m5.xlarge", associate_public_ip_address = false },
]


tags = {
  Environment = "development"
}

clusters = [
  { name = "dev-db-cluster", create_cluster = true, multi_az = false },
]

enabled_cloudwatch_logs_exports = ["error", "general"]
master_username = "dev_master_user"
kms_key_id      = "dev-kms-key-id"
kms_key_arn     = "arn:aws:kms:us-west-2:739275445379:key/dev-kms-key-arn"

