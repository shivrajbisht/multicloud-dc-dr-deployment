# ==============================================================================
# AZURE NSG MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "vnet_cidr" {
  type        = string
  description = "VNet CIDR block used for intra-VNet allow rules"
}

variable "bastion_allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDRs allowed to SSH into Bastion NSG (restrict to VPN/Office IP ranges)"
}

# Dynamic ingress rules for application subnet NSG
variable "app_inbound_rules" {
  type = list(object({
    name                   = string
    priority               = number
    direction              = string
    access                 = string
    protocol               = string
    source_port_range      = string
    destination_port_range = string
    source_address_prefix  = string
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
