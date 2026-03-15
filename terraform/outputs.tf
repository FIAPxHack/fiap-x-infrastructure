output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.video_processing.url
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.video_processing_dlq.url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.video_storage.bucket
}

output "ecr_worker_url" {
  value = aws_ecr_repository.video_processor.repository_url
}

output "ecr_manager_url" {
  value = aws_ecr_repository.video_manager.repository_url
}

output "rds_endpoint" {
  value = aws_db_instance.manager.address
}

output "rds_secret_arn" {
  value     = aws_db_instance.manager.master_user_secret[0].secret_arn
  sensitive = false
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "rds_auth_endpoint" {
  value = aws_db_instance.auth.address
}

output "rds_auth_secret_arn" {
  value = aws_db_instance.auth.master_user_secret[0].secret_arn
}

output "rds_user_endpoint" {
  value = aws_db_instance.user.address
}

output "rds_user_secret_arn" {
  value = aws_db_instance.user.master_user_secret[0].secret_arn
}

output "video_processor_role_arn" {
  value = aws_iam_role.video_processor.arn
}

output "video_manager_role_arn" {
  value = aws_iam_role.video_manager.arn
}

output "user_role_arn" {
  value = aws_iam_role.user.arn
}

output "auth_role_arn" {
  value = aws_iam_role.auth.arn
}

output "notification_role_arn" {
  value = aws_iam_role.notification.arn
}