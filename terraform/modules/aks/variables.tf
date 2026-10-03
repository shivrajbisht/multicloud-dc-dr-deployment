# ==============================================================================
# AZURE AKS MODULE - VARIABLES DEFINITION
# ==============================================================================
# Defines all input parameters for provisioning a production-ready Azure AKS cluster.
# Completely parameterized without hardcoded values for multi-environment reusability.
# ==============================================================================

# ------------------------------------------------------------------------------
# Resource Group & Location
# ------------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group housing AKS resources"
}

variable "location" {
  type        = string
  description = "Azure region location (e.g., eastus, westeurope, uksouth)"
}

# ------------------------------------------------------------------------------
# Cluster General Configuration
# ------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "Name of the Azure Kubernetes Service (AKS) cluster (e.g., dr-aks-prod-01)"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.36"
  description = "Target Kubernetes version for AKS control plane and node pools"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster"
}

variable "environment" {
  type        = string
  description = "Deployment environment scope (e.g., dev, uat, prod)"
}

# ------------------------------------------------------------------------------
# Networking & Subnet Inputs (3 Private Subnet Integration)
# ------------------------------------------------------------------------------

variable "vnet_subnet_id" {
  type        = string
  description = "Resource ID of the private VNet subnet where AKS worker nodes and pods will be attached"
}

variable "pod_cidr" {
  type        = string
  default     = "10.244.0.0/16"
  description = "CIDR range used for Kubernetes Pod IP allocation (Azure CNI Overlay / kubenet)"
}

variable "service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Network CIDR used to assign IP addresses to internal Kubernetes services"
}

variable "dns_service_ip" {
  type        = string
  default     = "10.0.0.10"
  description = "IP address within service_cidr reserved for CoreDNS service"
}

# ------------------------------------------------------------------------------
# System Node Pool Configuration (On-Demand)
# ------------------------------------------------------------------------------

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
}

# ------------------------------------------------------------------------------
# User Node Pool 1 Configuration (Spot Scale Set Pool)
# ------------------------------------------------------------------------------

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
}

# ------------------------------------------------------------------------------
# User Node Pool 2 Configuration (On-Demand Scale Set Pool)
# ------------------------------------------------------------------------------

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
}

# ------------------------------------------------------------------------------
# Resource Tagging Standard
# ------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all Azure resources provisioned by this module"
}
