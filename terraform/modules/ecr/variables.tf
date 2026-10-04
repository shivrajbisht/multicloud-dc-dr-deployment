# ==============================================================================
# AWS ECR MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "repository_name" {
  type        = string
  description = "Name of the AWS Elastic Container Registry repository"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._/-]{1,255}$", var.repository_name))
    error_message = "ECR REPOSITORY NAME ERROR: repository_name must start with lowercase letter/digit and contain valid ECR repo characters (2-256 chars)."
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

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "MUTABILITY ERROR: image_tag_mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
