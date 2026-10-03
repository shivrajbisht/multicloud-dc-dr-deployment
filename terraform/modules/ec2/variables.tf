# ==============================================================================
# AWS EC2 MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type - t3.medium for bastion, m6i.xlarge for app servers"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance will be placed"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs to attach to the EC2 instance"
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
}

variable "root_volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type (gp3 recommended for performance)"
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
  description = "EC2 user data bootstrap script content (base64 encoded or plain)"
}

variable "iam_instance_profile_name" {
  type        = string
  default     = null
  description = "Optional IAM Instance Profile name for SSM Session Manager access"
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
