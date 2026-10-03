# ==============================================================================
# AZURE POSTGRESQL FLEXIBLE SERVER MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "server_name" {
  type        = string
  description = "Unique name for the Azure PostgreSQL Flexible Server"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "subnet_id" {
  type        = string
  description = "Delegated VNet Subnet ID for private server integration"
}

variable "key_vault_key_id" {
  type        = string
  description = "Azure Key Vault Key ID for Customer Managed Key (CMK) encryption at rest"
}

variable "admin_username" {
  type        = string
  default     = "pgadmin"
  description = "Administrator username"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password"
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
