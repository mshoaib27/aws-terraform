region         = "us-east-1"
vpc_cidr       = ["11.1.0.0/16"]
num_azs        = 4

clusters = [
  {
    name           = "clients-01"
    create_cluster = true
    min_capacity   = 0.5
    max_capacity   = 8
  },
  {
    name           = "cross-clients"
    create_cluster = true
    min_capacity   = 0.5
    max_capacity   = 8
  },
  {
    name           = "onboarding"
    create_cluster = false
    min_capacity   = 0.5
    max_capacity   = 2
  }
]

database         = "postgres"
db_host_port     = 5432
master_username  = "masterpgsql"

aws_profile = "us-staging-profile"  