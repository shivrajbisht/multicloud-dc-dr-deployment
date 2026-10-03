# ==============================================================================
# AZURE CONTAINER REGISTRY (ACR) MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "name" {
  type        = string
  description = "Globally unique name of the Azure Container Registry (alphanumeric)"
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
