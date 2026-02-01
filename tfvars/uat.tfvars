account_id      = "419344669752"
region        = "eu-west-1"
num_azs       = 3
vpc_cidr      = ["10.1.0.0/24"]
ami_id        = "ami-03446a3af42c5e74e"  ##uuntu 24.04 AMI
key_name      = "tasctower"

instances = [
  { name = "tt-uat-app", create_instance = true, instance_type = "m5.large", ami_id = "ami-03446a3af42c5e74e", associate_public_ip_address = false },
]

rds_instance_name = "tt-uat"


rds_instance_class    = "db.m5.large"
rds_allocated_storage = 60
rds_storage_type      = "gp3"
rds_storage_encrypted = true


rds_engine           = "mysql"
rds_engine_version   = "8.0"
rds_parameter_family = "mysql8.0"


master_username = "admin"
master_password = "SuperUserOneTwoThree"


rds_backup_retention = 7
rds_multi_az         = false


rds_deletion_protection = true

rds_monitoring_interval            = 5
rds_enable_cloudwatch_logs_exports = ["error", "general", "slowquery"]


rds_apply_immediately     = true
rds_copy_tags_to_snapshot = true
rds_publicly_accessible   = false

tags = {
  Environment = "tt-qatar-uat"
  Project     = "tt-qatar"
}


create_alb                 = true
alb_name                   = "tt-uat-alb"
internal                   = false
enable_deletion_protection = false
certificate_arn            = "arn:aws:acm:eu-west-1:419344669752:certificate/a5bf83b8-e069-4094-9c48-9e5bfb4c5928"

# For certificate import, create a terraform.auto.tfvars.json file with certificate content
# or pass via -var flags: terraform plan -var="certificate_body=..." -var="certificate_private_key=..."
# For now, leaving empty to use ALB without HTTPS listener


