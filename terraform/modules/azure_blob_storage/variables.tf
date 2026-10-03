# ==============================================================================
# AZURE BLOB STORAGE MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "storage_account_name" {
  type        = string
  description = "Globally unique name for the Azure Storage Account (3-24 alphanumeric lowercase)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "key_vault_key_id" {
  type        = string
  description = "Azure Key Vault Key ID for Customer Managed Key (CMK) encryption"
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
