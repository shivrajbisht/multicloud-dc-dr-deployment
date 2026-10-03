# ==============================================================================
# AWS GITHUB OIDC MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "role_arn" {
  description = "ARN of the IAM Role created for GitHub Actions OIDC Authentication"
  value       = aws_iam_role.github_actions_role.arn
}

output "provider_arn" {
  description = "ARN of the IAM OIDC Provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
