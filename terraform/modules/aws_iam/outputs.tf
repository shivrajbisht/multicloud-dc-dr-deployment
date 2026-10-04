# ==============================================================================
# AWS IAM MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "devops_admins_group_arn" {
  description = "ARN of the DevOps Admins IAM Group"
  value       = aws_iam_group.devops_admins.arn
}

output "developers_group_arn" {
  description = "ARN of the Developers IAM Group"
  value       = aws_iam_group.developers.arn
}

output "security_auditors_group_arn" {
  description = "ARN of the Security Auditors IAM Group"
  value       = aws_iam_group.security_auditors.arn
}

output "app_workload_role_arn" {
  description = "ARN of the Application Workload IAM Role"
  value       = aws_iam_role.app_workload_role.arn
}

output "app_workload_policy_arn" {
  description = "ARN of the Customer Managed App Workload Policy"
  value       = aws_iam_policy.app_workload_policy.arn
}
