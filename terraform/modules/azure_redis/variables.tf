# ==============================================================================
# AZURE REDIS / VALKEY MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "name" {
  type        = string
  description = "Name of the Azure Cache for Redis instance (1-63 alphanumeric characters or hyphens)"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "REDIS NAME ERROR: name must contain 1-63 lowercase alphanumeric characters or hyphens."
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

variable "capacity" {
  type        = number
  default     = 1
  description = "Redis SKU capacity (e.g. 1 for P1 Premium)"

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 5
    error_message = "CAPACITY ERROR: capacity must be between 1 and 5 for Azure Redis Premium tier."
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
