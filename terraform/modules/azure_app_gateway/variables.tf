# ==============================================================================
# AZURE APPLICATION GATEWAY V2 MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "appgw_name" {
  type        = string
  description = "Name of the Azure Application Gateway"
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
  description = "Dedicated Subnet ID in Azure VNet for Application Gateway placement"
}

variable "sku_name" {
  type        = string
  default     = "Standard_v2" # Standard_v2 or WAF_v2
  description = "Application Gateway SKU tier name"
}

variable "capacity" {
  type        = number
  default     = 2
  description = "Autoscaling or fixed capacity instance count"
}

variable "ssl_certificate_secret_id" {
  type        = string
  default     = null
  description = "Azure Key Vault Secret ID containing PFX certificate for SSL termination"
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
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
