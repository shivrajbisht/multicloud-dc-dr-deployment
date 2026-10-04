# ==============================================================================
# AZURE POSTGRESQL FLEXIBLE SERVER MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "server_name" {
  type        = string
  description = "Unique name for the Azure PostgreSQL Flexible Server"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.server_name))
    error_message = "AZURE SERVER NAME ERROR: server_name must consist of lowercase alphanumeric characters or hyphens (3-63 chars)."
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
  description = "Azure region location (e.g. eastus, westeurope)"

  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralindia", "uksouth"], var.location)
    error_message = "REGION VALIDATION ERROR: location must be an approved Azure region."
  }
}

variable "subnet_id" {
  type        = string
  description = "Delegated VNet Subnet ID for private server integration"

  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "SUBNET ERROR: subnet_id cannot be empty."
  }
}

variable "key_vault_key_id" {
  type        = string
  description = "Azure Key Vault Key ID for Customer Managed Key (CMK) encryption at rest"
  sensitive   = true # CMK Key URI contains sensitive key metadata
}

variable "admin_username" {
  type        = string
  default     = "pgadmin"
  description = "Administrator username"
  sensitive   = true # SENSITIVE CREDENTIAL MASKED FROM LOGS

  validation {
    condition     = length(var.admin_username) >= 4 && !contains(["admin", "postgres", "root"], var.admin_username)
    error_message = "SECURITY COMPLIANCE ERROR: Admin username cannot be generic ('admin', 'postgres', 'root') and must be at least 4 characters."
  }
}

variable "admin_password" {
  type        = string
  sensitive   = true # SENSITIVE CREDENTIAL MASKED FROM LOGS & TF STATE OUTPUT

  validation {
    condition     = length(var.admin_password) >= 12 && can(regex("[A-Z]", var.admin_password)) && can(regex("[a-z]", var.admin_password)) && can(regex("[0-9]", var.admin_password))
    error_message = "PASSWORD COMPLEXITY ERROR: Administrator password must be at least 12 characters and contain uppercase, lowercase, and numeric characters."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, staging, prod)"

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
