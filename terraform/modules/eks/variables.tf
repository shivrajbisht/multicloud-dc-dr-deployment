# ==============================================================================
# AWS EKS MODULE - VARIABLES DEFINITION
# ==============================================================================
# This file defines all configurable parameters for the EKS Terraform module.
# No values are hardcoded to ensure full reusability across environments (DEV/UAT/PROD).
# ==============================================================================

# ------------------------------------------------------------------------------
# Cluster General Configuration
# ------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "Unique identifier name for the EKS cluster (e.g., dc-eks-prod-01)"
}

variable "cluster_version" {
  type        = string
  default     = "1.36"
  description = "Kubernetes control plane version (Targeting K8s version 1.36)"
}

variable "environment" {
  type        = string
  description = "Deployment environment scope (e.g., dev, uat, prod)"
}

# ------------------------------------------------------------------------------
# Network Infrastructure Inputs
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where EKS control plane and worker nodes will be provisioned"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of exactly 3 private subnet IDs across different Availability Zones for HA nodegroups"

  validation {
    condition     = length(var.private_subnet_ids) == 3
    error_message = "Must provide exactly 3 private subnet IDs across distinct Availability Zones."
  }
}

# ------------------------------------------------------------------------------
# EKS Node Pools / Node Groups Configuration (3 Node Groups: 1 On-Demand, 2 Spot)
# ------------------------------------------------------------------------------

# 1. On-Demand Node Group (Primary system workloads, ingress, operators)
variable "on_demand_node_group" {
  type = object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
  })
  default = {
    name           = "ondemand-core-pool"
    instance_types = ["m6i.large", "m5.large"]
    min_size       = 2
    max_size       = 6
    desired_size   = 3
    disk_size      = 50
  }
  description = "Configuration for the primary On-Demand EKS Managed Node Group"
}

# 2. Spot Node Group 1 (Stateless app workloads - Pool A)
variable "spot_node_group_1" {
  type = object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
  })
  default = {
    name           = "spot-app-pool-a"
    instance_types = ["c6i.large", "c5.large", "m6i.large"]
    min_size       = 1
    max_size       = 10
    desired_size   = 3
    disk_size      = 50
  }
  description = "Configuration for the first Spot EKS Managed Node Group"
}

# 3. Spot Node Group 2 (Batch/Secondary app workloads - Pool B)
variable "spot_node_group_2" {
  type = object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
  })
  default = {
    name           = "spot-app-pool-b"
    instance_types = ["r6i.large", "r5.large", "m5a.large"]
    min_size       = 1
    max_size       = 10
    desired_size   = 3
    disk_size      = 50
  }
  description = "Configuration for the second Spot EKS Managed Node Group"
}

# ------------------------------------------------------------------------------
# Security & Access Control Parameters
# ------------------------------------------------------------------------------

variable "enable_public_endpoint" {
  type        = bool
  default     = false
  description = "Whether the Amazon EKS public API server endpoint is enabled"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
}

# ------------------------------------------------------------------------------
# Tagging Standard
# ------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags to be applied across all AWS resources created by this module"
}
