variable "create_alb" {
  description = "Flag to determine if ALB should be created"
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs to attach the ALB to"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
}
