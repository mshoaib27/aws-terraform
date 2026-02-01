variable "customer_name" {
  description = "Customer name for naming conventions"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "lambda_filename" {
  description = "Path to lambda function zip file"
  type        = string
  default     = "lambda_function.zip"
}

variable "notification_emails" {
  description = "Email addresses for SNS subscriptions"
  type        = list(string)
  default = [
    "infra@nexsysone.com",
    "performance@nxsysone.com",
    "nxosupport.tier1@nexsysone.com",
    "Leads@nexsysone.com",
    "support.automation@nexsysone.com",
    "Product.dev@nexsysone.com",
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs for alarm creation"
  type        = list(string)
  default     = []
}

variable "rds_instance_ids" {
  description = "RDS instance IDs for alarm creation"
  type        = list(string)
  default     = []
}

variable "efs_filesystem_ids" {
  description = "EFS filesystem IDs for alarm creation"
  type        = list(string)
  default     = []
}

variable "alb_arns" {
  description = "Application Load Balancer ARNs for alarm creation"
  type        = list(string)
  default     = []
}
