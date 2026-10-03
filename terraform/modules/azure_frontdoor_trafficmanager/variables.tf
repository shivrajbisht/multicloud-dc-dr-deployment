# ==============================================================================
# AZURE FRONT DOOR & TRAFFIC MANAGER MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "profile_name" {
  type        = string
  description = "Name of the Front Door profile"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "dc_eks_ingress_host" {
  type        = string
  description = "Primary DC EKS Ingress Load Balancer domain / IP"
}

variable "dr_aks_ingress_host" {
  type        = string
  description = "Secondary DR AKS Ingress Load Balancer domain / IP"
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
