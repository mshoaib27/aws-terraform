# output "nlbhost_reader" {
#    value = aws_lb.nlb_reader.dns_name
#  }

# output "nlbhost_writer" {
#    value = aws_lb.nlb_writer.dns_name
#  }

# # output "rds_writer_tg_arn" {
# #   value = aws_lb_target_group.rds_writer_tg_1.arn
# # }

# # output "rds_reader_tg_arn" {
# #   value = aws_lb_target_group.rds_reader_tg_2.arn
# # }

# # output "writer_endpoint" {
# #   value = aws_lb_target_group.rds_writer_tg.taget_ip_address
  
# # }

# output "rds_writer_endpoint" {
#   value = [for cluster in local.clusters : module.aurora_postgresql_v2[cluster.name].writer_endpoint]
# }

# output "rds_reader_endpoint" {
#   value = [for cluster in local.clusters : module.aurora_postgresql_v2[cluster.name].reader_endpoint]
# }

# output "cluster_endpoint" {
#   value = { for k, v in module.aurora_postgresql_v2 : k => v.cluster_endpoint }
# }
 
# output "cluster_reader_endpoint" {
#   value = { for k, v in module.aurora_postgresql_v2 : k => v.cluster_reader_endpoint }
# }