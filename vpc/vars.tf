variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/24"]
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 3
}