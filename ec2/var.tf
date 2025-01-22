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