######################### RDS Instance Outputs #########################

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.rds_instance.id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_address" {
  description = "RDS instance address (without port)"
  value       = aws_db_instance.rds_instance.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds_instance.port
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.rds_instance.identifier
}

output "rds_resource_id" {
  description = "RDS resource ID"
  value       = aws_db_instance.rds_instance.resource_id
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.rds_instance.arn
}

output "rds_engine" {
  description = "RDS database engine"
  value       = aws_db_instance.rds_instance.engine
}

output "rds_engine_version" {
  description = "RDS database engine version"
  value       = aws_db_instance.rds_instance.engine_version
}

output "rds_instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.rds_instance.instance_class
}

output "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  value       = aws_db_instance.rds_instance.allocated_storage
}

output "rds_storage_type" {
  description = "RDS storage type"
  value       = aws_db_instance.rds_instance.storage_type
}

output "rds_storage_encrypted" {
  description = "RDS storage encryption status"
  value       = aws_db_instance.rds_instance.storage_encrypted
}

output "rds_backup_retention_period" {
  description = "RDS backup retention period in days"
  value       = aws_db_instance.rds_instance.backup_retention_period
}

output "rds_multi_az" {
  description = "RDS multi-AZ deployment status"
  value       = aws_db_instance.rds_instance.multi_az
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.rds_instance.username
  sensitive   = false
}

output "rds_publicly_accessible" {
  description = "RDS public accessibility status"
  value       = aws_db_instance.rds_instance.publicly_accessible
}

output "rds_instance_all_details" {
  description = "All RDS instance details"
  value = {
    id                = aws_db_instance.rds_instance.id
    identifier        = aws_db_instance.rds_instance.identifier
    endpoint          = aws_db_instance.rds_instance.endpoint
    address           = aws_db_instance.rds_instance.address
    port              = aws_db_instance.rds_instance.port
    resource_id       = aws_db_instance.rds_instance.resource_id
    arn               = aws_db_instance.rds_instance.arn
    engine            = aws_db_instance.rds_instance.engine
    engine_version    = aws_db_instance.rds_instance.engine_version
    instance_class    = aws_db_instance.rds_instance.instance_class
    allocated_storage = aws_db_instance.rds_instance.allocated_storage
    storage_encrypted = aws_db_instance.rds_instance.storage_encrypted
    multi_az          = aws_db_instance.rds_instance.multi_az
    backup_retention  = aws_db_instance.rds_instance.backup_retention_period
    username          = aws_db_instance.rds_instance.username
    tags              = aws_db_instance.rds_instance.tags
  }
}

output "rds_subnet_group_id" {
  description = "RDS subnet group ID"
  value       = aws_db_subnet_group.rds_db_subnet_group.id
}

output "rds_subnet_group_arn" {
  description = "RDS subnet group ARN"
  value       = aws_db_subnet_group.rds_db_subnet_group.arn
}

output "rds_parameter_group_id" {
  description = "RDS parameter group ID"
  value       = aws_db_parameter_group.rds_params.id
}

output "rds_parameter_group_arn" {
  description = "RDS parameter group ARN"
  value       = aws_db_parameter_group.rds_params.arn
}

output "rds_option_group_id" {
  description = "RDS option group ID"
  value       = aws_db_option_group.rds_options.id
}

output "rds_option_group_arn" {
  description = "RDS option group ARN"
  value       = aws_db_option_group.rds_options.arn
}

output "rds_monitoring_role_arn" {
  description = "RDS monitoring role ARN"
  value       = aws_iam_role.rds_monitoring.arn
}

output "rds_monitoring_role_name" {
  description = "RDS monitoring role name"
  value       = aws_iam_role.rds_monitoring.name
}

output "rds_connection_string" {
  description = "RDS MySQL connection string (use with caution - contains credentials)"
  value       = "mysql://${aws_db_instance.rds_instance.username}:<password>@${aws_db_instance.rds_instance.endpoint}/${var.rds_engine}"
  sensitive   = true
}
