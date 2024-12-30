variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

variable "clusters" {
  description = "A list of maps containing cluster configurations."
  type = list(object({
    name                = string
    create_cluster      = bool
    multi_az            = bool
#    reader_count         = number
#    reader_instance_class = string
#    writer_instance_class = string

  }))
  default = [
    { name = "test-1", create_cluster = false, multi_az = false,  },
    { name = "test-2", create_cluster = true, multi_az = true, },
  ]
}

variable "private_subnets" {
  type = list(string)
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
  default = "mastermysql"
}

variable "kms_key_id" {
  default = ""
}

variable "sg_id" {
  type = list(string)
}
