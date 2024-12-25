region         = "sa-east-1"
vpc_cidr       = ["12.1.0.0/16"]
num_azs        = 4

instances = [
  {
    name            = "sba-test-app"
    create_instance = true
    instance_type   = "t3.micro"
    associate_public_ip_address = false
  }
]
key_name = "test"
ami_id = "ami-1234567890abcdef0"