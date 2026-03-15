locals {
  oidc_provider     = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
}

# ==========================================
# VIDEO PROCESSOR - IAM Role (SQS + S3)
# ==========================================
resource "aws_iam_role" "video_processor" {
  name = "${var.project_name}-video-processor-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:default:video-processor-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "video_processor" {
  name = "${var.project_name}-video-processor-policy"
  role = aws_iam_role.video_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.video_processing.arn,
          aws_sqs_queue.video_processing_dlq.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.video_storage.arn,
          "${aws_s3_bucket.video_storage.arn}/*"
        ]
      }
    ]
  })
}

# ==========================================
# VIDEO MANAGER - IAM Role (S3 + Secrets Manager)
# ==========================================
resource "aws_iam_role" "video_manager" {
  name = "${var.project_name}-video-manager-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:default:video-manager-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "video_manager" {
  name = "${var.project_name}-video-manager-policy"
  role = aws_iam_role.video_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.video_storage.arn,
          "${aws_s3_bucket.video_storage.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_db_instance.manager.master_user_secret[0].secret_arn]
      }
    ]
  })
}

# ==========================================
# USER - IAM Role 
# ==========================================
resource "aws_iam_role" "user" {
  name = "${var.project_name}-user-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:default:fiap-x-user-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "user" {
  name = "${var.project_name}-user-policy"
  role = aws_iam_role.user.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_db_instance.user.master_user_secret[0].secret_arn]
      }
    ]
  })
}

# ==========================================
# AUTH - IAM Role
# ==========================================
resource "aws_iam_role" "auth" {
  name = "${var.project_name}-auth-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:default:fiap-x-auth-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "auth" {
  name = "${var.project_name}-auth-policy"
  role = aws_iam_role.auth.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_db_instance.auth.master_user_secret[0].secret_arn]
      }
    ]
  })
}

# ==========================================
# NOTIFICATION 
# ==========================================
resource "aws_iam_role" "notification" {
  name = "${var.project_name}-notification-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:default:fiap-x-notification-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "notification" {
  name = "${var.project_name}-notification-policy"
  role = aws_iam_role.notification.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sqs:SendMessage"
        ]
        Resource = "*"
      }
    ]
  })
}