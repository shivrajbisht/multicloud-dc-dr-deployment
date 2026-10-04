# ==============================================================================
# AWS EC2 MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"

  # NAME VALIDATION
  validation {
    condition     = length(var.instance_name) > 0
    error_message = "COMPLIANCE ERROR: instance_name cannot be empty."
  }
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type - t3.medium for bastion, m6i.xlarge for app servers"

  # INSTANCE TYPE COMPLIANCE
  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "COMPLIANCE ERROR: instance_type must be a valid AWS EC2 instance type (e.g., t3.medium, m6i.xlarge)."
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance will be placed"

  # SUBNET FORMAT VALIDATION
  validation {
    condition     = can(regex("^subnet-[a-f0-9]{8,17}$", var.subnet_id))
    error_message = "COMPLIANCE ERROR: subnet_id must be a valid AWS Subnet ID starting with 'subnet-'."
  }
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs to attach to the EC2 instance"

  # SECURITY GROUP VALIDATION
  validation {
    condition     = length(var.security_group_ids) > 0 && alltrue([for sg in var.security_group_ids : can(regex("^sg-[a-f0-9]{8,17}$", sg))])
    error_message = "COMPLIANCE ERROR: security_group_ids must be a non-empty list of valid AWS Security Group IDs starting with 'sg-'."
  }
}

variable "key_pair_name" {
  type        = string
  description = "AWS EC2 Key Pair name for SSH access"
}

variable "associate_public_ip" {
  type        = bool
  default     = false
  description = "Whether to associate a public IP address (true for Bastion, false for app servers)"
}

variable "root_volume_size_gb" {
  type        = number
  default     = 30
  description = "Root EBS volume size in GB"

  # STORAGE SIZE VALIDATION
  validation {
    condition     = var.root_volume_size_gb >= 20
    error_message = "COMPLIANCE ERROR: root_volume_size_gb must be at least 20 GB for OS disk performance and compliance."
  }
}

variable "root_volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type (gp3 recommended for performance)"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "COMPLIANCE ERROR: root_volume_type must be one of ['gp2', 'gp3', 'io1', 'io2']."
  }
}

variable "additional_ebs_volumes" {
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
    encrypted   = bool
  }))
  default     = []
  description = "List of additional EBS volumes to attach (dynamic block used in main.tf)"
}

variable "user_data" {
  type        = string
  default     = ""
  sensitive   = true
  description = "EC2 user data bootstrap script content (marked sensitive to protect inline secrets)"
}

variable "iam_instance_profile_name" {
  type        = string
  default     = null
  description = "Optional IAM Instance Profile name for SSM Session Manager access"
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
