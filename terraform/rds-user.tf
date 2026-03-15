resource "aws_db_subnet_group" "user" {
  name       = "${var.project_name}-user-subnet-${var.environment}"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.project_name}-user-subnet"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds_user" {
  name        = "${var.project_name}-rds-user-sg-${var.environment}"
  description = "Security group for User RDS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
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
    Name        = "${var.project_name}-rds-user-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "user" {
  identifier     = "${var.project_name}-user-db-${var.environment}"
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "db_fiap_x_user"
  username = "admin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.user.name
  vpc_security_group_ids = [aws_security_group.rds_user.id]

  publicly_accessible = false
  skip_final_snapshot  = true

  tags = {
    Name        = "${var.project_name}-user-db"
    Environment = var.environment
  }
}