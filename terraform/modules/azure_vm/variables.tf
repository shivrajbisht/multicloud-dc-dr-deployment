# ==============================================================================
# AZURE VIRTUAL MACHINE (VM) MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vm_name" {
  type        = string
  description = "Name of the Azure Virtual Machine"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D4s_v5"
  description = "Azure VM size (e.g., Standard_B2s for Bastion, Standard_D4s_v5 for App VMs)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the NIC will be attached"
}

variable "nsg_id" {
  type        = string
  description = "Network Security Group ID to associate with the NIC"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Administrator username for SSH access"
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
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
