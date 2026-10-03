# ==============================================================================
# AWS GITHUB OIDC MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "github_org" {
  type        = string
  description = "GitHub Organization or username (e.g., my-company-org)"
}

variable "github_repo" {
  type        = string
  description = "GitHub Repository name allowed to authenticate via OIDC (e.g., multicloud-dc-dr-deployment)"
}

variable "role_name" {
  type        = string
  default     = "GitHubActionsDeployerRole"
  description = "IAM Role Name created for GitHub Actions"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
