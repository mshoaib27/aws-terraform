variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for Redis"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Redis"
  type        = list(string)
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
