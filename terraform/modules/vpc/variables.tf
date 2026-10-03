# ==============================================================================
# AWS VPC MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Base CIDR block for the VPC"
}

variable "vpc_name" {
  type        = string
  default     = "dc-primary-vpc"
  description = "Name tag for the VPC infrastructure"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, prod)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
