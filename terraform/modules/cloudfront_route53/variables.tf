# ==============================================================================
# AWS ROUTE 53 & CLOUDFRONT MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "domain_name" {
  type        = string
  description = "Primary domain name (e.g., app.example.com)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "DOMAIN NAME ERROR: domain_name must be a valid FQDN (e.g. app.example.com)."
  }
}

variable "s3_bucket_origin_domain" {
  type        = string
  description = "Regional domain name of the origin S3 bucket"

  validation {
    condition     = length(var.s3_bucket_origin_domain) > 0
    error_message = "S3 ORIGIN ERROR: s3_bucket_origin_domain cannot be empty."
  }
}

variable "dc_eks_ingress_ip" {
  type        = string
  description = "Primary DC EKS Ingress Load Balancer IP / DNS"

  validation {
    condition     = length(var.dc_eks_ingress_ip) > 0
    error_message = "INGRESS IP ERROR: dc_eks_ingress_ip cannot be empty."
  }
}

variable "dr_aks_ingress_ip" {
  type        = string
  description = "Secondary DR AKS Ingress Load Balancer IP / DNS"

  validation {
    condition     = length(var.dr_aks_ingress_ip) > 0
    error_message = "INGRESS IP ERROR: dr_aks_ingress_ip cannot be empty."
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
