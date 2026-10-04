# ==============================================================================
# AZURE AKS MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group housing AKS resources"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "RESOURCE GROUP ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location (e.g., eastus, westeurope, uksouth)"

  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralindia", "uksouth"], var.location)
    error_message = "AZURE REGION ERROR: location must be an approved Azure region."
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the Azure Kubernetes Service (AKS) cluster (e.g., dr-aks-prod-01)"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.cluster_name))
    error_message = "AKS CLUSTER NAME ERROR: cluster_name must contain lowercase alphanumeric characters or hyphens (3-63 chars)."
  }
}

variable "kubernetes_version" {
  type        = string
  default     = "1.36"
  description = "Target Kubernetes version for AKS control plane and node pools"

  validation {
    condition     = contains(["1.28", "1.29", "1.30", "1.31", "1.32", "1.36"], var.kubernetes_version)
    error_message = "K8S VERSION ERROR: kubernetes_version must be a supported Kubernetes version."
  }
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,54}$", var.dns_prefix))
    error_message = "DNS PREFIX ERROR: dns_prefix must contain lowercase alphanumeric characters or hyphens (3-54 chars)."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment scope (e.g., dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "vnet_subnet_id" {
  type        = string
  description = "Resource ID of the private VNet subnet where AKS worker nodes and pods will be attached"

  validation {
    condition     = length(var.vnet_subnet_id) > 0
    error_message = "SUBNET ERROR: vnet_subnet_id cannot be empty."
  }
}

variable "pod_cidr" {
  type        = string
  default     = "10.244.0.0/16"
  description = "CIDR range used for Kubernetes Pod IP allocation (Azure CNI Overlay / kubenet)"

  validation {
    condition     = can(cidrnetmask(var.pod_cidr))
    error_message = "POD CIDR ERROR: pod_cidr must be a valid IPv4 CIDR string."
  }
}

variable "service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Network CIDR used to assign IP addresses to internal Kubernetes services"

  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "SERVICE CIDR ERROR: service_cidr must be a valid IPv4 CIDR string."
  }
}

variable "dns_service_ip" {
  type        = string
  default     = "10.0.0.10"
  description = "IP address within service_cidr reserved for CoreDNS service"

  validation {
    condition     = can(cidrnetmask("${var.dns_service_ip}/32"))
    error_message = "DNS SERVICE IP ERROR: dns_service_ip must be a valid IPv4 address."
  }
}

variable "system_node_pool" {
  type = object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    os_disk_size_gb     = number
    zones               = list(string)
  })
  default = {
    name                = "syspool"
    vm_size             = "Standard_D4s_v5"
    node_count          = 3
    min_count           = 3
    max_count           = 6
    enable_auto_scaling = true
    os_disk_size_gb     = 64
    zones               = ["1", "2", "3"]
  }
  description = "Configuration parameters for the System Node Pool (On-Demand Core components)"

  validation {
    condition     = var.system_node_pool.node_count >= 3 && var.system_node_pool.min_count >= 3 && var.system_node_pool.os_disk_size_gb >= 30
    error_message = "SYSTEM NODE POOL ERROR: system_node_pool requires node_count >= 3, min_count >= 3, and os_disk_size_gb >= 30 for HA compliance."
  }
}

variable "spot_user_node_pool" {
  type = object({
    name                = string
    vm_size             = string
    min_count           = number
    max_count           = number
    desired_count       = number
    os_disk_size_gb     = number
    zones               = list(string)
    max_price           = number # -1 for market price
  })
  default = {
    name                = "spotpool1"
    vm_size             = "Standard_D4s_v5"
    min_count           = 1
    max_count           = 10
    desired_count       = 3
    os_disk_size_gb     = 64
    zones               = ["1", "2", "3"]
    max_price           = -1
  }
  description = "Configuration parameters for Azure Spot Virtual Machine Scale Set Node Pool"

  validation {
    condition     = var.spot_user_node_pool.min_count >= 1 && var.spot_user_node_pool.max_count >= var.spot_user_node_pool.min_count && var.spot_user_node_pool.desired_count >= var.spot_user_node_pool.min_count
    error_message = "SPOT NODE POOL ERROR: desired_count and max_count must be greater than or equal to min_count."
  }
}

variable "ondemand_user_node_pool" {
  type = object({
    name                = string
    vm_size             = string
    min_count           = number
    max_count           = number
    desired_count       = number
    os_disk_size_gb     = number
    zones               = list(string)
  })
  default = {
    name                = "apppool2"
    vm_size             = "Standard_E4s_v5"
    min_count           = 1
    max_count           = 10
    desired_count       = 3
    os_disk_size_gb     = 64
    zones               = ["1", "2", "3"]
  }
  description = "Configuration parameters for Azure On-Demand Virtual Machine Scale Set User Node Pool"

  validation {
    condition     = var.ondemand_user_node_pool.min_count >= 1 && var.ondemand_user_node_pool.max_count >= var.ondemand_user_node_pool.min_count && var.ondemand_user_node_pool.desired_count >= var.ondemand_user_node_pool.min_count
    error_message = "ON-DEMAND NODE POOL ERROR: desired_count and max_count must be greater than or equal to min_count."
  }
}

variable "app_gateway_id" {
  type        = string
  default     = null
  description = "Optional Azure Application Gateway Resource ID for automatic AGIC ingress integration"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all Azure resources provisioned by this module"
}
