# resource "aws_rds_cluster_parameter_group" "custom_cluster_pg" {
#   name        = "custom-cluster-pg"
#   family      = "aurora-postgresql13"  # Adjust this based on your Aurora/PostgreSQL version
#   description = "Custom cluster parameter group"

#   parameter {
#     name  = "temp_buffers"
#     value = "262144"
#   }

#   parameter {
#     name  = "work_mem"
#     value = "131072"
#   }
# }


# resource "aws_db_parameter_group" "custom_instance_pg" {
#   name        = "custom-instance-pg"
#   family      = "postgres13"  # Adjust this based on your PostgreSQL version
#   description = "Custom instance parameter group"

#   parameter {
#     name  = "temp_buffers"
#     value = "262144"
#   }

#   parameter {
#     name  = "work_mem"
#     value = "131072"
#   }
# }
