variable "region" {
  description = "AWS region"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "clusters" {
  description = "Configuration for RDS MySQL instances"
  type = list(object({
    name            = string
    create_instance = bool
  }))
}

variable "kms_key_id" {
  description = "KMS Key ID for encrypting RDS storage"
  type        = string
}

variable "master_username" {
  description = "Master username for RDS instances"
  type        = string
}

variable "sg_id" {
  description = "Security Group ID for RDS instances"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
