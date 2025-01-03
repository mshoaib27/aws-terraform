variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/25"]
}

variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

variable "private_subnets" {
  type = list(string)
}