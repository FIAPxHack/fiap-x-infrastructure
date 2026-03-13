resource "aws_sqs_queue" "video_processing_dlq" {
  name                      = "${var.project_name}-dlq-${var.environment}"
  message_retention_seconds = 1209600 
}

resource "aws_sqs_queue" "video_processing" {
  name                       = "${var.project_name}-queue-${var.environment}"
  visibility_timeout_seconds = 900 
  message_retention_seconds  = 86400 
  receive_wait_time_seconds  = 20 

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })
}