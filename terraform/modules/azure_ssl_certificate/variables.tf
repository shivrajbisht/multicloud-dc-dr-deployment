# ==============================================================================
# AZURE SSL CERTIFICATE MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "certificate_name" {
  type        = string
  description = "Unique name for the SSL certificate in Azure Key Vault"
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Azure Key Vault"
}

variable "dns_names" {
  type        = list(string)
  description = "List of Subject Alternative Names (DNS names) for the certificate"
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
