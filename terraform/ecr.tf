resource "aws_ecr_repository" "video_processor" {
  name                 = "${var.project_name}-worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-worker"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "video_manager" {
  name                 = "${var.project_name}-manager"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-manager"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "user" {
  name                 = "fiapx-user"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "fiapx-user"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "auth" {
  name                 = "fiapx-auth"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "fiapx-auth"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "notification" {
  name                 = "fiapx-notification"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "fiapx-notification"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "api_gateway" {
  name                 = "fiapx-api-gateway"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "fiapx-api-gateway"
    Environment = var.environment
  }
}