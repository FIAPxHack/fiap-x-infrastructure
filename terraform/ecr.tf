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