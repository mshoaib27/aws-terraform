# output "postgresql_cluster_id" {
#  description = "The RDS Cluster Identifier"
#  value = { for k, v in module.rds_mysql : k => v.cluster_id }
#}

# output "rds_cluster_ids" {
#   description = "List of RDS cluster IDs"
#   value       = [for cluster in module.aurora_postgresql_v2 : cluster.cluster_id]
# }

# output "rds_cluster_endpoints" {
#   description = "Endpoints for each RDS cluster"
#   value       = { for k, v in module.aurora_postgresql_v2 : k => v.endpoint }
# }

# output "rds_reader_endpoints" {
#   description = "Reader endpoints for each RDS cluster"
#   value       = { for k, v in module.aurora_postgresql_v2 : k => v.reader_endpoint }
# }

# # output "db_subnet_group_names" {
# #   description = "Names of the RDS DB subnet groups"
# #   value       = [for name, subnet in aws_db_subnet_group.aurora_db_subnet_group : subnet.name]
# # }s

# output "db_master_passwords" {
#   description = "Master passwords for each RDS cluster"
#   sensitive   = true
#   value       = { for k, v in random_password.master : k => v.result }
# }

# output "rds_cluster_identifiers" {
#   value = { for name, cluster in module.aurora_postgresql_v2 : name => cluster.this_db_cluster_id }
#   description = "Identifiers for the RDS clusters created in this module"
# }