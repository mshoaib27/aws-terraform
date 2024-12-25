region         = "us-east-1"
vpc_cidr       = ["11.1.0.0/16"]
num_azs        = 4

clusters = [
  {
    name           = "clients-8-b"
    create_cluster = true
    min_capacity   = 0.5
    max_capacity   = 3
  },
  {
    name           = "clients-4-7"
    create_cluster = true
    min_capacity   = 0.5
    max_capacity   = 1
  },
  {
    name           = "clients-0-3"
    create_cluster = false
    min_capacity   = 0.5
    max_capacity   = 1
  },
  {
    name           = "clients-c-f"
    create_cluster = false
    min_capacity   = 0.5
    max_capacity   = 2
  }
]

database         = "postgres"
db_host_port     = 5432
master_username  = "masterpgsql"
create_cognito = false
create_ses = false