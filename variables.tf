############################################### Region #####################################

variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

########################################## VPC #############################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/25"]
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 4
}

########################################## EC2 #############################################

variable "instances" {
  description = "List of EC2 instances configuration"
  type = list(
    object({
      name                        = string
      instance_type               = string
      ami_id                      = string
      associate_public_ip_address = bool
      create_instance             = bool
    })
  )
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default = ""
}

variable "key_name" {
  description = "The key pair name for SSH access to EC2 instances"
  type        = string
}

variable "name" {
  type = string
  default = "null"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch. Supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "production"
  }
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default = ""
}

variable "private_ip" {
description = "private ip of ec2 instances"
type = string
default = ""
}

########################################## RDS #############################################

variable "rds_instance_name" {
  description = "Name of the RDS instance"
  type        = string
  default     = "dev-db-instance"
}

variable "rds_instance_class" {
  description = "The instance class for RDS (e.g., db.m6g.2xlarge)"
  type        = string
  default     = "db.m6g.2xlarge"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS instance"
  type        = number
  default     = 100
}

variable "rds_storage_type" {
  description = "Storage type for RDS (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "rds_storage_encrypted" {
  description = "Whether to enable storage encryption"
  type        = bool
  default     = true
}

variable "rds_backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Whether to enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "master_username" {
  description = "Master username for RDS instances"
  type        = string
}

variable "master_password" {
  description = "Master password for RDS instances"
  type        = string
  sensitive   = true
}

variable "rds_engine" {
  description = "RDS database engine (mysql, postgres, etc.)"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "RDS database engine version"
  type        = string
  default     = "8.0"
}

variable "rds_parameter_family" {
  description = "RDS parameter family"
  type        = string
  default     = "mysql8.0"
}

variable "rds_monitoring_interval" {
  description = "RDS enhanced monitoring interval in seconds"
  type        = number
  default     = 5
}

variable "rds_enable_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch"
  type        = list(string)
  default     = ["error", "general", "slowquery"]
}

variable "rds_apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = true
}

variable "rds_copy_tags_to_snapshot" {
  description = "Whether to copy tags to snapshots"
  type        = bool
  default     = true
}

variable "rds_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

# Deprecated: clusters variable (use individual RDS variables instead)
variable "clusters" {
  description = "Configuration for RDS MySQL instances (DEPRECATED - for backward compatibility)"
  type = list(object({
    name            = string
    create_instance = bool
  }))
  default = []
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  type        = string
  description = "Specifies the kms key used for this project."
  default     = null
}

variable "account_id" {
  type = string
  default = "739275445379"
}

variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
  default = ""
}

variable "private_subnets" {
  description = "List of private subnet IDs for Redis"
  type        = list(string)
  default = [ "" ]
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Redis"
  type        = list(string)
  default =  ["" ]
}

variable "node_type" {
  description = "The instance class for the Redis cluster (e.g., cache.t3.micro)"
  type        = string
  default = ""
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the Redis cluster"
  type        = number
  default = 1
}

variable "create_alb" {
  description = "Flag to determine if ALB should be created"
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default = "prod-alb"
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = "arn:aws:acm:eu-west-1:419344669752:certificate/a5bf83b8-e069-4094-9c48-9e5bfb4c5928"
}