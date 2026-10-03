# ==============================================================================
# AWS S3 BUCKET MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, prod)"
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
