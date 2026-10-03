# ==============================================================================
# AWS S3 BUCKET MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "bucket_id" {
  description = "The name/ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "kms_key_arn" {
  description = "ARN of the AWS KMS Customer Managed Key used for S3 encryption"
  value       = aws_kms_key.s3_kms_key.arn
}
