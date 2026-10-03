# ==============================================================================
# AZURE GITHUB OIDC MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "identity_name" {
  type        = string
  default     = "id-github-actions-deployer"
  description = "Name of the User Assigned Identity for GitHub Actions"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "github_org" {
  type        = string
  description = "GitHub Organization or username"
}

variable "github_repo" {
  type        = string
  description = "GitHub Repository name"
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
