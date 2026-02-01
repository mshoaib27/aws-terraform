variable "region" {
  description = "AWS region"
  type        = string
}

variable "customer_name" {
  description = "Customer name for alarm naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "emails" {
  description = "List of emails for SNS subscriptions"
  type        = list(string)
  default = [
    "infra@nexsysone.com",
    "performance@nxsysone.com",
    "nxosupport.tier1@nexsysone.com",
    "Leads@nexsysone.com",
    "support.automation@nexsysone.com",
    "Product.dev@nexsysone.com",
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}
