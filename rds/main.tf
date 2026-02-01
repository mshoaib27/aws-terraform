######################### RDS Instance Creation #########################

# Create RDS Subnet Group
resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name        = "${var.rds_instance_name}-subnet-group"
  description = "Subnet group for the RDS instance"
  subnet_ids  = var.private_subnets

  tags = merge(
    var.tags,
    {
      Name = "${var.rds_instance_name}-subnet-group"
    }
  )
}

# Create Standalone RDS MySQL Instance
resource "aws_db_instance" "rds_instance" {
  identifier                  = var.rds_instance_name
  engine                      = var.rds_engine
  engine_version              = var.rds_engine_version
  instance_class              = var.rds_instance_class
  allocated_storage           = var.rds_allocated_storage
  storage_type                = var.rds_storage_type
  storage_encrypted           = var.rds_storage_encrypted
  username                    = var.master_username
  password                    = var.master_password
  
  db_subnet_group_name        = aws_db_subnet_group.rds_db_subnet_group.name
  vpc_security_group_ids      = var.sg_id
  
  parameter_group_name        = aws_db_parameter_group.rds_params.name
  option_group_name           = aws_db_option_group.rds_options.name
  
  multi_az                    = var.rds_multi_az
  backup_retention_period     = var.rds_backup_retention
  backup_window               = "03:00-04:00"
  maintenance_window          = "mon:04:00-mon:05:00"
  
  deletion_protection         = var.rds_deletion_protection
  skip_final_snapshot         = true
  
  monitoring_interval         = var.rds_monitoring_interval
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = var.rds_enable_cloudwatch_logs_exports
  
  apply_immediately           = var.rds_apply_immediately
  auto_minor_version_upgrade  = true
  
  copy_tags_to_snapshot       = var.rds_copy_tags_to_snapshot
  publicly_accessible         = var.rds_publicly_accessible
  iam_database_authentication_enabled = false

  tags = merge(
    var.tags,
    {
      Name = var.rds_instance_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.rds_monitoring
  ]
}

# RDS Parameter Group
resource "aws_db_parameter_group" "rds_params" {
  name        = "${var.rds_instance_name}-params"
  description = "Parameter group for ${var.rds_instance_name}"
  family      = var.rds_parameter_family

  parameter {
    name  = "connect_timeout"
    value = "30"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.rds_instance_name}-params"
    }
  )
}

# RDS Option Group
resource "aws_db_option_group" "rds_options" {
  name                     = "${var.rds_instance_name}-options"
  option_group_description = "Option group for ${var.rds_instance_name}"
  engine_name              = var.rds_engine
  major_engine_version     = "${split(".", var.rds_engine_version)[0]}.${split(".", var.rds_engine_version)[1]}"

  tags = merge(
    var.tags,
    {
      Name = "${var.rds_instance_name}-options"
    }
  )
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.rds_instance_name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.rds_instance_name}-monitoring-role"
    }
  )
}

# IAM Role Policy Attachment for RDS Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

