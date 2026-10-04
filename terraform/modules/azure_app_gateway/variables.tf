# ==============================================================================
# AZURE APPLICATION GATEWAY V2 MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "appgw_name" {
  type        = string
  description = "Name of the Azure Application Gateway"

  # NAME VALIDATION
  validation {
    condition     = length(var.appgw_name) > 0 && length(var.appgw_name) <= 50
    error_message = "COMPLIANCE ERROR: appgw_name must be between 1 and 50 characters long."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  # RESOURCE GROUP VALIDATION
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "COMPLIANCE ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location"

  # LOCATION VALIDATION
  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralus"], lower(var.location))
    error_message = "COMPLIANCE ERROR: location must be an approved Azure region e.g. ['eastus', 'eastus2', 'westus', 'westeurope', 'northeurope', 'centralus']."
  }
}

variable "subnet_id" {
  type        = string
  description = "Dedicated Subnet ID in Azure VNet for Application Gateway placement"
}

variable "sku_name" {
  type        = string
  default     = "Standard_v2" # Standard_v2 or WAF_v2
  description = "Application Gateway SKU tier name"

  # SKU VALIDATION
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "COMPLIANCE ERROR: sku_name must be either 'Standard_v2' or 'WAF_v2'."
  }
}

variable "capacity" {
  type        = number
  default     = 2
  description = "Autoscaling or fixed capacity instance count"

  # CAPACITY VALIDATION
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 32
    error_message = "COMPLIANCE ERROR: capacity must be between 1 and 32 instances for Application Gateway v2."
  }
}

variable "ssl_certificate_secret_id" {
  type        = string
  default     = null
  sensitive   = true
  description = "Azure Key Vault Secret ID containing PFX certificate for SSL termination (marked sensitive)"
}

variable "backend_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of target Pod / VM private IP addresses for backend pool"
}

variable "health_check_path" {
  type        = string
  default     = "/healthz"
  description = "HTTP probe path for health checks"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"

  # ENVIRONMENT SCOPING VALIDATION
  validation {
    condition     = contains(["dev", "staging", "prod", "dr"], var.environment)
    error_message = "COMPLIANCE ERROR: environment must be one of ['dev', 'staging', 'prod', 'dr']."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
