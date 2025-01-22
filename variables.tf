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
  description = "A list of maps containing EC2 instance configurations."
  type = list(object({
    name                    = string
    create_instance         = bool
    instance_type           = string
    associate_public_ip_address = bool  # Whether to associate a public IP
  }))
  default = [
    { name = "sba-app-01", create_instance = false, instance_type = "m5.large", associate_public_ip_address = false },
  ]
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
    Environment = "staging"
  }
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default = ""
}

########################################## RDS #############################################

variable "clusters" {
  description = "A list of maps containing cluster configurations."
  type = list(object({
    name                = string
    create_cluster      = bool
    multi_az            = bool
   # reader_count         = number
   # reader_instance_class = string
   # writer_instance_class = string

  }))
  default = [
    { name = "test-1", create_cluster = false, multi_az = false, },
    { name = "test-2", create_cluster = false, multi_az = false,  },
  ]
}
/* 
variable "private_subnets" {
  type = list(string)
} */

variable "master_username" {
  default = "masterpgsql"
}

variable "kms_key_id" {
  default = ""
}

variable "kms_key_arn" {
  type        = string
  description = "Specifies the kms key used for this project."
  default     = null
}

/*  variable "sg_id" {
  type = list(string)
}  */

variable "account_id" {
  type = string
  default = "739275445379"
}