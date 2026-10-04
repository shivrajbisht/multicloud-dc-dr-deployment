# ==============================================================================
# AWS GITHUB OIDC MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "github_org" {
  type        = string
  description = "GitHub Organization or username (e.g., my-company-org)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.github_org))
    error_message = "GITHUB ORG ERROR: github_org must contain valid GitHub organization or username characters."
  }
}

variable "github_repo" {
  type        = string
  description = "GitHub Repository name allowed to authenticate via OIDC (e.g., multicloud-dc-dr-deployment)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.github_repo))
    error_message = "GITHUB REPO ERROR: github_repo must contain valid GitHub repository name characters."
  }
}

variable "role_name" {
  type        = string
  default     = "GitHubActionsDeployerRole"
  description = "IAM Role Name created for GitHub Actions"

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@-]{1,64}$", var.role_name))
    error_message = "IAM ROLE NAME ERROR: role_name must be a valid AWS IAM role name (1-64 chars)."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
