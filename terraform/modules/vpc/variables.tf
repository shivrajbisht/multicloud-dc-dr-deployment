# ==============================================================================
# AWS VPC MODULE - VARIABLES DEFINITION (WITH CUSTOM VALIDATIONS)
# ==============================================================================

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Base IPv4 CIDR block for the AWS VPC"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "SECURITY & COMPLIANCE ERROR: vpc_cidr must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 20
    error_message = "COMPLIANCE ERROR: vpc_cidr prefix length must be /20 or larger (e.g. /16) to ensure sufficient IP allocation for subnets."
  }
}

variable "vpc_name" {
  type        = string
  default     = "dc-primary-vpc"
  description = "Name tag for the VPC infrastructure"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,64}$", var.vpc_name))
    error_message = "NAMING STANDARD ERROR: vpc_name must consist of lowercase alphanumeric characters or hyphens, between 3 and 64 characters long."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags applied to VPC components"
}
