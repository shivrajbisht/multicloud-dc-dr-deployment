# ==============================================================================
# AWS ECR MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.repo.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS Key used for ECR encryption"
  value       = aws_kms_key.ecr_kms_key.arn
}
