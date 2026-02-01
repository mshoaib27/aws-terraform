
account_id = "423623839339"
region     = "sa-east-1"
vpc_cidr = ["10.1.16.0/24"]
num_azs  = 4
ami_id   = "ami-0dccf463b6ff559ff"

key_name = "sba-prod"

instances = [
  {
    name                        = "sba-preprod-app-01"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-0975628249d7e8952"
    associate_public_ip_address = false
    create_instance             = true
  },
  {
    name                        = "sba-preprod-cron"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-0975628249d7e8952"
    associate_public_ip_address = false
    create_instance             = true
  },
{
  name                        = "sba-preprod-sftp"
  instance_type               = "t4g.medium"
  ami_id                      = "ami-04d1bc0e151921904"
  associate_public_ip_address = true
  create_instance             = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 30
    }
  ]
}

/** {
    name                        = "sba-preprod-cron-01"
    instance_type               = "m5.xlarge"
    ami_id                      = "ami-0dccf463b6ff559ff"
    associate_public_ip_address = false
    create_instance             = false
    private_ip   = "11.1.0.62/32"
  }, */

/*   {
    name      = "preprod-jump"
    instance_type = "t3.micro"
    ami_id       = "ami-0780816dd7ce942fd"
    associate_public_ip_address = true
    create_instance = true
  }, */
]

# RDS Configuration

master_username = "sbamaster"
clusters = [
  {
    name            = "sba-preprod-db"
    create_instance = true
  }
]


# Tags
tags = {
  Environment = "preprod"
}

# RDS Additional Configuration
enabled_cloudwatch_logs_exports = ["error", "general","audit","slowquery"]

# KMS Configuration
kms_key_id  = "preprod-kms-key-id"
kms_key_arn = "arn:aws:kms:us-west-2:739275445379:key/preprod-kms-key-arn"


redis_cluster_id = "preprod-cluster"
node_type        = "cache.r6g.12xlarge"
allowed_cidr_blocks = ["11.1.0.0/16"]
num_cache_nodes  = 1



create_alb              = true
alb_name                = "preproduction-APP-LB"
internal                = false
enable_deletion_protection = false

