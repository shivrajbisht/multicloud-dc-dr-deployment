# ==============================================================================
# AWS KEY PAIR MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "key_name" {
  type        = string
  description = "Name of the EC2 Key Pair to create (used for SSH access)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.key_name))
    error_message = "KEY NAME ERROR: key_name must contain 1-255 alphanumeric characters, hyphens, or underscores."
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
