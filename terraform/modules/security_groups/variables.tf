# ==============================================================================
# AWS SECURITY GROUPS MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block used for intra-VPC ingress rules"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
}

# -----------------------------------------------------------------------
# DYNAMIC INGRESS RULES: Each security group accepts a list of ingress
# rule objects. This enables flexible rule definitions without hardcoding.
# -----------------------------------------------------------------------
variable "bastion_ingress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed SSH access to Bastion Host (restrict in prod to office/vpn CIDRs)"
}

variable "app_ec2_ingress_ports" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
  description = "Dynamic ingress rules for Application EC2 security group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
