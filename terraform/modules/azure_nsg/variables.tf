# ==============================================================================
# AZURE NSG MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  # SECURITY COMPLIANCE VALIDATION
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "COMPLIANCE ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location"

  # LOCATION COMPLIANCE VALIDATION
  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralus"], lower(var.location))
    error_message = "COMPLIANCE ERROR: location must be an approved Azure region e.g. ['eastus', 'eastus2', 'westus', 'westeurope', 'northeurope', 'centralus']."
  }
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

variable "vnet_cidr" {
  type        = string
  description = "VNet CIDR block used for intra-VNet allow rules"

  # SECURITY COMPLIANCE VALIDATION
  validation {
    condition     = can(cidrnetmask(var.vnet_cidr))
    error_message = "COMPLIANCE ERROR: vnet_cidr must be a valid IPv4 CIDR block format (e.g., 10.0.0.0/16)."
  }
}

variable "bastion_allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDRs allowed to SSH into Bastion NSG (restrict to VPN/Office IP ranges)"

  # SECURITY AUDIT VALIDATION
  validation {
    condition     = length(var.bastion_allowed_ssh_cidrs) > 0 && alltrue([for cidr in var.bastion_allowed_ssh_cidrs : can(cidrnetmask(cidr))])
    error_message = "SECURITY COMPLIANCE ERROR: bastion_allowed_ssh_cidrs must be a non-empty list of valid IPv4 CIDR blocks."
  }
}

# Dynamic ingress rules for application subnet NSG
variable "app_inbound_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default     = []
  description = "Dynamic list of inbound NSG rules for the Application Subnet NSG"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
