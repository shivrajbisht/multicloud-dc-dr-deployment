# ==============================================================================
# ELASTICACHE VALKEY MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "replication_group_id" {
  description = "ID of the Valkey replication group"
  value       = aws_elasticache_replication_group.valkey.id
}

output "primary_endpoint_address" {
  description = "Primary endpoint address for read/write operations"
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
}

output "kms_key_arn" {
  description = "ARN of the AWS KMS Customer Managed Key used for Valkey encryption at rest"
  value       = aws_kms_key.valkey_kms_key.arn
}

output "security_group_id" {
  description = "Security group ID attached to the Valkey cluster"
  value       = aws_security_group.valkey_sg.id
}
