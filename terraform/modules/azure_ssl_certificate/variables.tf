# ==============================================================================
# AZURE SSL CERTIFICATE MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "certificate_name" {
  type        = string
  description = "Unique name for the SSL certificate in Azure Key Vault"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,127}$", var.certificate_name))
    error_message = "CERTIFICATE NAME ERROR: certificate_name must contain 1-127 alphanumeric characters or hyphens."
  }
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Azure Key Vault"

  validation {
    condition     = length(var.key_vault_id) > 0
    error_message = "KEY VAULT ID ERROR: key_vault_id cannot be empty."
  }
}

variable "dns_names" {
  type        = list(string)
  description = "List of Subject Alternative Names (DNS names) for the certificate"

  validation {
    condition     = length(var.dns_names) > 0
    error_message = "DNS NAMES ERROR: dns_names must contain at least one valid domain name."
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
