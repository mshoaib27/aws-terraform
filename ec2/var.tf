variable "instances" {
  description = "A list of maps containing EC2 instance configurations."
  type = list(object({
    name                    = string
    create_instance         = bool
    instance_type           = string
    associate_public_ip_address = bool
    subnet_id                = list(string)  
  }))
  default = [  ]
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default = "value"
}

variable "key_name" {
  description = "The key pair name for SSH access to EC2 instances"
  type        = string
  default = "sba-prod"
}


variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string

}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "name" {
  type = string
}