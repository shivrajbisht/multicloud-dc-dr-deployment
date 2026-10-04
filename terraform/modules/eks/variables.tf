# ==============================================================================
# AWS EKS MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "cluster_name" {
  type        = string
  description = "Unique identifier name for the EKS cluster (e.g., dc-eks-prod-01)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{1,99}$", var.cluster_name))
    error_message = "EKS CLUSTER NAME ERROR: cluster_name must start with alphanumeric char and contain only alphanumeric, hyphen, or underscore (2-100 chars)."
  }
}

variable "cluster_version" {
  type        = string
  default     = "1.36"
  description = "Kubernetes control plane version (Targeting K8s version 1.36)"

  validation {
    condition     = contains(["1.28", "1.29", "1.30", "1.31", "1.32", "1.36"], var.cluster_version)
    error_message = "K8S VERSION ERROR: cluster_version must be a supported Kubernetes version (e.g. 1.36)."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment scope (dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where EKS control plane and worker nodes will be provisioned"

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID ERROR: vpc_id must be a valid AWS VPC ID starting with 'vpc-'."
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of exactly 3 private subnet IDs across different Availability Zones for HA nodegroups"

  validation {
    condition     = length(var.private_subnet_ids) == 3 && alltrue([for s in var.private_subnet_ids : can(regex("^subnet-[a-f0-9]+$", s))])
    error_message = "HA SUBNET ERROR: Must provide exactly 3 valid private subnet IDs starting with 'subnet-' across distinct Availability Zones."
  }
}

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

  validation {
    condition     = var.on_demand_node_group.min_size >= 1 && var.on_demand_node_group.max_size >= var.on_demand_node_group.min_size && var.on_demand_node_group.desired_size >= var.on_demand_node_group.min_size
    error_message = "ON DEMAND NODE GROUP ERROR: desired_size and max_size must be greater than or equal to min_size."
  }
}

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

  validation {
    condition     = var.spot_node_group_1.min_size >= 1 && var.spot_node_group_1.max_size >= var.spot_node_group_1.min_size && var.spot_node_group_1.desired_size >= var.spot_node_group_1.min_size
    error_message = "SPOT NODE GROUP 1 ERROR: desired_size and max_size must be greater than or equal to min_size."
  }
}

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

  validation {
    condition     = var.spot_node_group_2.min_size >= 1 && var.spot_node_group_2.max_size >= var.spot_node_group_2.min_size && var.spot_node_group_2.desired_size >= var.spot_node_group_2.min_size
    error_message = "SPOT NODE GROUP 2 ERROR: desired_size and max_size must be greater than or equal to min_size."
  }
}

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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags to be applied across all AWS resources created by this module"
}
