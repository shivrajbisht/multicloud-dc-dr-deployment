# ==============================================================================
# AZURE VIRTUAL MACHINE (VM) MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vm_name" {
  type        = string
  description = "Name of the Azure Virtual Machine"

  # NAME VALIDATION
  validation {
    condition     = length(var.vm_name) > 0
    error_message = "COMPLIANCE ERROR: vm_name cannot be empty."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"

  # RESOURCE GROUP VALIDATION
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "COMPLIANCE ERROR: resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region location"

  # LOCATION VALIDATION
  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westeurope", "northeurope", "centralus"], lower(var.location))
    error_message = "COMPLIANCE ERROR: location must be an approved Azure region e.g. ['eastus', 'eastus2', 'westus', 'westeurope', 'northeurope', 'centralus']."
  }
}

variable "vm_size" {
  type        = string
  default     = "Standard_D4s_v5"
  description = "Azure VM size (e.g., Standard_B2s for Bastion, Standard_D4s_v5 for App VMs)"

  validation {
    condition     = can(regex("^Standard_[A-Za-z0-9_]+$", var.vm_size))
    error_message = "VM SIZE ERROR: vm_size must be a valid Azure VM SKU starting with 'Standard_'."
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the NIC will be attached"

  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "SUBNET ID ERROR: subnet_id cannot be empty."
  }
}

variable "nsg_id" {
  type        = string
  description = "Network Security Group ID to associate with the NIC"

  validation {
    condition     = length(var.nsg_id) > 0
    error_message = "NSG ID ERROR: nsg_id cannot be empty."
  }
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Administrator username for SSH access"

  validation {
    condition     = length(var.admin_username) >= 4 && !contains(["admin", "root", "administrator"], var.admin_username)
    error_message = "SECURITY ERROR: admin_username must be at least 4 characters and cannot be generic ('admin', 'root', 'administrator')."
  }
}

variable "associate_public_ip" {
  type        = bool
  default     = false
  description = "Whether to assign a Public IP to the VM NIC (true for Bastion only)"
}

variable "os_disk_size_gb" {
  type        = number
  default     = 64
  description = "OS disk size in GB"

  # DISK SIZE VALIDATION
  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "COMPLIANCE ERROR: os_disk_size_gb must be at least 30 GB for Azure Linux VMs."
  }
}

variable "additional_data_disks" {
  type = list(object({
    name         = string
    disk_size_gb = number
    lun          = number
    caching      = string
  }))
  default     = []
  description = "List of additional managed data disks to attach (dynamic block)"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"

  # ENVIRONMENT SCOPING VALIDATION
  validation {
    condition     = contains(["dev", "staging", "prod", "dr"], var.environment)
    error_message = "COMPLIANCE ERROR: environment must be one of ['dev', 'staging', 'prod', 'dr']."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
