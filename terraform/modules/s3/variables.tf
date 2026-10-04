# ==============================================================================
# AWS S3 BUCKET MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "BUCKET NAME ERROR: bucket_name must be 3-63 characters long, contain only lowercase letters, numbers, hyphens, and periods."
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

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Whether S3 bucket versioning is enabled"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to S3 resources"
}
