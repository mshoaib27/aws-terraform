
# Security Group for Redis
resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Security group for Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["11.1.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "redis-sg"
    }
  )
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = var.private_subnets[0]

  tags = merge(
    var.tags,
    {
      Name = "redis-subnet-group"
    }
  )
}

# Redis Cluster
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = var.redis_cluster_id
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = merge(
    var.tags,
    {
      Name = var.redis_cluster_id
    }
  )
}
