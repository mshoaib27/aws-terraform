############################################### Region #####################################

variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

########################################## VPC #############################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["12.1.0.0/25"]
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 4
}

########################################## EC2 #############################################

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
}

variable "key_name" {
  description = "The key pair name for SSH access to EC2 instances"
  type        = string
}

variable "name" {
  type = string
  default = "null"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch. Supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "production"
  }
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default = ""
}

########################################## RDS #############################################

variable "clusters" {
  description = "Configuration for RDS MySQL instances"
  type = list(object({
    name            = string
    create_instance = bool
  }))
}


variable "master_username" {
  description = "Master username for RDS instances"
  type        = string
  default = ""
}


variable "kms_key_id" {
  default = ""
}

variable "kms_key_arn" {
  type        = string
  description = "Specifies the kms key used for this project."
  default     = null
}


variable "account_id" {
  type = string
  default = "739275445379"
}


variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
  default = ""
}

variable "private_subnets" {
  description = "List of private subnet IDs for Redis"
  type        = list(string)
  default = [ "" ]
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Redis"
  type        = list(string)
  default =  ["" ]
}

variable "redis_cluster_id" {
  description = "ID for the Redis cluster"
  type        = string
}

variable "node_type" {
  description = "The instance class for the Redis cluster (e.g., cache.t3.micro)"
  type        = string
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the Redis cluster"
  type        = number
}

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
variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB"
  type        = bool
  default     = false
}