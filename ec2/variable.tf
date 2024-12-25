variable "instances" {
  description = "A list of maps containing EC2 instance configurations."
  type = list(object({
    name                    = string
    create_instance         = bool
    instance_type           = string
    associate_public_ip_address = bool  # Whether to associate a public IP
  }))
  default = [
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
  type        = map(string)
} */

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
