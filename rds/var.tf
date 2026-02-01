variable "region" {
  description = "AWS region"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
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

variable "sg_id" {
  description = "Security Group ID for RDS instances"
  type        = list(string)
}

variable "kms_key_id" {
  description = "KMS Key ID for encrypting RDS storage"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

######################### RDS Instance Variables #########################

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

