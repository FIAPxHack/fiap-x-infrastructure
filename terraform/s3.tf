resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.project_name}-storage-${var.environment}"
}

resource "aws_s3_bucket_notification" "video_upload" {
  bucket = aws_s3_bucket.video_storage.id

  queue {
    queue_arn     = aws_sqs_queue.video_processing.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  depends_on = [aws_sqs_queue_policy.allow_s3]
}

resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.video_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "SQS:SendMessage"
        Resource  = aws_sqs_queue.video_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.video_storage.arn
          }
        }
      }
    ]
  })
}