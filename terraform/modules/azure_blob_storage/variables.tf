# ==============================================================================
# AZURE BLOB STORAGE MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "storage_account_name" {
  type        = string
  description = "Globally unique name for the Azure Storage Account (3-24 alphanumeric lowercase)"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "STORAGE ACCOUNT NAME ERROR: storage_account_name must be 3-24 lowercase alphanumeric characters."
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

variable "key_vault_key_id" {
  type        = string
  description = "Azure Key Vault Key ID for Customer Managed Key (CMK) encryption"

  validation {
    condition     = length(var.key_vault_key_id) > 0
    error_message = "KEY VAULT KEY ID ERROR: key_vault_key_id cannot be empty."
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
