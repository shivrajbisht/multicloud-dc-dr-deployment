# ==============================================================================
# AZURE VNET MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vnet_name" {
  type        = string
  description = "Name of the Azure Virtual Network"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "Address space CIDR for the Azure Virtual Network"
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
