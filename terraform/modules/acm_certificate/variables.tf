# ==============================================================================
# AWS ACM CERTIFICATE MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "domain_name" {
  type        = string
  description = "Primary domain name for the ACM SSL/TLS certificate (e.g., api.company.com)"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "List of Subject Alternative Names (SANs) e.g., *.api.company.com"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID used for automated DNS validation record creation"
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
