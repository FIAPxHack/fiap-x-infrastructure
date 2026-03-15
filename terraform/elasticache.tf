resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg-${var.environment}"
  description = "Security group for ElastiCache Redis"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-redis-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-${var.environment}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-cache-${var.environment}"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  port                 = 6379
  parameter_group_name = "default.redis7"

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  tags = {
    Name        = "${var.project_name}-redis-${var.environment}"
    Environment = var.environment
  }
}