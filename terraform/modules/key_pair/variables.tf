# ==============================================================================
# AWS KEY PAIR MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "key_name" {
  type        = string
  description = "Name of the EC2 Key Pair to create (used for SSH access)"
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
