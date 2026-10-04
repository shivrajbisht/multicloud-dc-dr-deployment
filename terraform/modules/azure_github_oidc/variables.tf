# ==============================================================================
# AZURE GITHUB OIDC MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "identity_name" {
  type        = string
  default     = "id-github-actions-deployer"
  description = "Name of the User Assigned Identity for GitHub Actions"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{3,128}$", var.identity_name))
    error_message = "IDENTITY NAME ERROR: identity_name must contain 3-128 alphanumeric characters, hyphens, or underscores."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "RESOURCE GROUP ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location"

  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralindia", "uksouth"], var.location)
    error_message = "AZURE REGION ERROR: location must be an approved Azure region."
  }
}

variable "github_org" {
  type        = string
  description = "GitHub Organization or username"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.github_org))
    error_message = "GITHUB ORG ERROR: github_org must contain valid GitHub organization or username characters."
  }
}

variable "github_repo" {
  type        = string
  description = "GitHub Repository name"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.github_repo))
    error_message = "GITHUB REPO ERROR: github_repo must contain valid GitHub repository name characters."
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
