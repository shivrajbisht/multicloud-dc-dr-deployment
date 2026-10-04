# ==============================================================================
# AZURE FRONT DOOR & TRAFFIC MANAGER MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "profile_name" {
  type        = string
  description = "Name of the Front Door profile (2-64 lowercase alphanumeric characters or hyphens)"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,64}$", var.profile_name))
    error_message = "PROFILE NAME ERROR: profile_name must contain 2-64 lowercase alphanumeric characters or hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "RESOURCE GROUP ERROR: resource_group_name cannot be empty."
  }
}

variable "dc_eks_ingress_host" {
  type        = string
  description = "Primary DC EKS Ingress Load Balancer domain / IP"

  validation {
    condition     = length(var.dc_eks_ingress_host) > 0
    error_message = "INGRESS HOST ERROR: dc_eks_ingress_host cannot be empty."
  }
}

variable "dr_aks_ingress_host" {
  type        = string
  description = "Secondary DR AKS Ingress Load Balancer domain / IP"

  validation {
    condition     = length(var.dr_aks_ingress_host) > 0
    error_message = "INGRESS HOST ERROR: dr_aks_ingress_host cannot be empty."
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
