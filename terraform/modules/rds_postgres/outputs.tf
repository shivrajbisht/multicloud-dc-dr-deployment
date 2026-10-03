# ==============================================================================
# AWS RDS POSTGRESQL 17 MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "db_instance_endpoint" {
  description = "Connection endpoint URL for the RDS PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_address" {
  description = "DNS hostname address of the RDS instance"
  value       = aws_db_instance.postgres.address
}

output "db_instance_id" {
  description = "RDS Database Instance identifier"
  value       = aws_db_instance.postgres.id
}

output "kms_key_arn" {
  description = "ARN of the AWS KMS Customer Managed Key used for EBS storage encryption"
  value       = aws_kms_key.rds_kms_key.arn
}

output "security_group_id" {
  description = "ID of the security group attached to the RDS PostgreSQL instance"
  value       = aws_security_group.rds_sg.id
}
