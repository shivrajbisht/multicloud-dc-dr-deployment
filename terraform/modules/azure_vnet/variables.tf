# ==============================================================================
# AZURE VNET MODULE - VARIABLES DEFINITION (WITH CUSTOM VALIDATIONS)
# ==============================================================================

variable "vnet_name" {
  type        = string
  description = "Name of the Azure Virtual Network"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,64}$", var.vnet_name))
    error_message = "NAMING COMPLIANCE ERROR: vnet_name must consist of lowercase alphanumeric characters or hyphens, between 3 and 64 characters long."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "VALIDATION ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location (e.g. eastus, westeurope)"

  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralindia", "uksouth"], var.location)
    error_message = "AZURE REGION ERROR: location must be an approved Azure region (e.g. eastus, westeurope, centralindia)."
  }
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "Address space CIDR blocks for the Azure Virtual Network"

  validation {
    condition     = length(var.vnet_address_space) > 0 && alltrue([for cidr in var.vnet_address_space : can(cidrnetmask(cidr))])
    error_message = "CIDR VALIDATION ERROR: Every entry in vnet_address_space must be a valid IPv4 CIDR string (e.g. 10.1.0.0/16)."
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
  description = "Resource tags applied to VNet infrastructure"
}
