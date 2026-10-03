# ==============================================================================
# ENVIRONMENT: DEV - VARIABLES DEFINITION
# ==============================================================================

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment name"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS target deployment region"
}

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure target deployment location"
}

variable "azure_resource_group" {
  type        = string
  default     = "rg-multicloud-dev-01"
  description = "Azure Resource Group name"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "AWS Primary VPC CIDR block"
}

variable "azure_vnet_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "Azure DR VNet CIDR block"
}

variable "bastion_ssh_allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDR ranges for Bastion host SSH access"
}
