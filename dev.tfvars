region         = "sa-east-1"
vpc_cidr       = ["12.1.0.0/16"]
num_azs        = 4
key_name = "test"
ami_id = "ami-1234567890abcdef0"

instances = [
    { name = "prod-app-01", create_instance = true, instance_type = "m5.large", associate_public_ip_address = false },
    { name = "prod-app-02", create_instance = true, instance_type = "m5.large", associate_public_ip_address = false },
    { name = "prod-api-01", create_instance = true, instance_type = "m5.large", associate_public_ip_address = false },
    { name = "prod-cron-01", create_instance = true, instance_type = "m5.large", associate_public_ip_address = false },
]

clusters = [
  { name = "prod-db-cluster", create_cluster = true, multi_az = true },
]

