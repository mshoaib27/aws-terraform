variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/25"]
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "staging"
  }
}