variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/25"]
}

variable "jumper_sg_id" {
  description = "Jumper security group ID"
  type        = string
}

variable "private_ec2_sg_id" {
  description = "Private EC2 instance security group ID"
  type        = string
  default     = ""
}

variable "efs_sg_id" {
  description = "EFS security group ID"
  type        = string
  default     = ""
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "staging"
  }
}