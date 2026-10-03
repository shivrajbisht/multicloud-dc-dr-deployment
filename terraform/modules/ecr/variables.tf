# ==============================================================================
# AWS ECR MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "repository_name" {
  type        = string
  description = "Name of the AWS Elastic Container Registry repository"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
