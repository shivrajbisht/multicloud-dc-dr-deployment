# ==============================================================================
# AZURE REDIS / VALKEY MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "name" {
  type        = string
  description = "Name of the Azure Cache for Redis instance"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Redis SKU capacity (e.g. 1 for P1 Premium)"
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
