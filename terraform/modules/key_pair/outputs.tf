# ==============================================================================
# AWS KEY PAIR MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "key_pair_name" {
  description = "Name of the AWS EC2 Key Pair"
  value       = aws_key_pair.ec2_key_pair.key_name
}

output "key_pair_fingerprint" {
  description = "MD5 fingerprint of the EC2 Key Pair public key"
  value       = aws_key_pair.ec2_key_pair.fingerprint
}

output "private_key_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the encrypted private key"
  value       = aws_secretsmanager_secret.private_key_secret.arn
}
