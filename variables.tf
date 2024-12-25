variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = list(string)
  default     = ["18.1.0.0/16"]
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 4
}

variable "instances" {
  description = "A list of maps containing EC2 instance configurations."
  type = list(object({
    name                    = string
    create_instance         = bool
    instance_type           = string
    associate_public_ip_address = bool  # Whether to associate a public IP
  }))
  default = [
    { name = "sba-test-app", create_instance = true, instance_type = "t3.micro", associate_public_ip_address = false },
  ]
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-1234567890abcdef0" # Replace with your desired AMI ID
}

variable "key_name" {
  description = "The key pair name for SSH access to EC2 instances"
  type        = string
  default     = "my-key-pair" # Replace with your key pair name
}

/* variable "subnets" {
  description = "List of private subnets where EC2 instances will be launched"
  type        = list(string)
} */ 

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch. Supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "staging"
  }
}