variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}

variable "clusters" {
  description = "A list of maps containing cluster configurations."
  type = list(object({
    name                = string
    create_cluster      = bool
    min_capacity        = number
    max_capacity        = number
  }))
  default = [
    { name = "clients-8-b",   create_cluster = false,   min_capacity = 0.5, max_capacity = 8 },
    { name = "clients-4-7", create_cluster = false,   min_capacity = 0.5, max_capacity = 8 },
    { name = "clients-0-3",   create_cluster = false,  min_capacity = 0.5, max_capacity = 2 },
     { name = "clients-c-f",   create_cluster = false,  min_capacity = 0.5, max_capacity = 1 },
  ]
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the Aurora RDS subnet group"
  type        = list(string)
}

variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch. Supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "staging"
  }
}

variable "master_username" {
  default = "masterpgsql"
}

variable "kms_key_id" {
  default = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/16"]
}

variable "sg_id" {
  type = list(string)
}
