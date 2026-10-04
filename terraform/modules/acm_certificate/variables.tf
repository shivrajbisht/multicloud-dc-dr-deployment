# ==============================================================================
# AWS ACM CERTIFICATE MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "domain_name" {
  type        = string
  description = "Primary domain name for the ACM SSL/TLS certificate (e.g., api.company.com)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "DOMAIN NAME ERROR: domain_name must be a valid FQDN (e.g., api.example.com)."
  }
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "List of Subject Alternative Names (SANs) e.g., *.api.company.com"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID used for automated DNS validation record creation"

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.route53_zone_id))
    error_message = "ROUTE53 ZONE ID ERROR: route53_zone_id must be a valid AWS Route 53 Zone ID starting with 'Z'."
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
