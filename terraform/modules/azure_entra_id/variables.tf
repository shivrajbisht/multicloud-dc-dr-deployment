# ==============================================================================
# AZURE ENTRA ID & RBAC MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "company_prefix" {
  type        = string
  default     = "multicloud"
  description = "Company or project prefix for Entra ID group naming"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.company_prefix))
    error_message = "COMPANY PREFIX ERROR: company_prefix must contain 3-24 lowercase alphanumeric characters or hyphens."
  }
}

variable "resource_group_id" {
  type        = string
  description = "Azure Resource Group ID for RBAC Role Assignments"

  validation {
    condition     = length(var.resource_group_id) > 0
    error_message = "RESOURCE GROUP ID ERROR: resource_group_id cannot be empty for RBAC scoping."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment scope (dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags applied to Azure infrastructure"
}
