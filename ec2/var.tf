# Variables and environment configuration
variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "Key pair name to use for EC2 instances"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "efs_dns_name" {
  description = "EFS DNS name for mounting"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
  default     = ""
}

# New naming convention variables
variable "app_server_names" {
  description = "List of app server names"
  type        = list(string)
  default     = []
}

variable "cron_server_names" {
  description = "List of cron server names"
  type        = list(string)
  default     = []
}

variable "api_server_names" {
  description = "List of API server names"
  type        = list(string)
  default     = []
}

variable "jumper_name" {
  description = "Jumper/bastion server name"
  type        = string
  default     = "jumper"
}

variable "app_server_instance_type" {
  description = "Instance type for app servers"
  type        = string
  default     = "m5.large"
}

variable "cron_server_instance_type" {
  description = "Instance type for cron servers"
  type        = string
  default     = "t3.medium"
}

variable "api_server_instance_type" {
  description = "Instance type for API servers"
  type        = string
  default     = "m5.xlarge"
}

variable "jumper_server_instance_type" {
  description = "Instance type for jumper/bastion server"
  type        = string
  default     = "t3.small"
}

# Deprecated - kept for backward compatibility
variable "instances" {
  description = "List of EC2 instances configuration (DEPRECATED - use app/cron/api server names)"
  type = list(
    object({
      name                        = string
      instance_type               = string
      ami_id                      = string
      associate_public_ip_address = bool
      create_instance             = bool
    })
  )
  default = []
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default = ""
}

variable "private_ip" {
  description = "private ip of ec2 instances"
  type        = string
  default     = ""
}


