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
variable "public_subnets" {
  type = list(string)
}

variable "register_targets" {
  description = "Whether to register targets to the target group"
  type        = bool
  default     = false
}

variable "target_instance_id" {
  description = "EC2 instance ID to register to the target group"
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = "arn:aws:acm:eu-west-1:419344669752:certificate/a5bf83b8-e069-4094-9c48-9e5bfb4c5928"
}