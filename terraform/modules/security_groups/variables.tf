# ==============================================================================
# AWS SECURITY GROUPS MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"

  # SECURITY COMPLIANCE VALIDATION
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "COMPLIANCE ERROR: vpc_id must be a valid AWS VPC ID starting with 'vpc-' followed by 8 or 17 hexadecimal characters."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block used for intra-VPC ingress rules"

  # SECURITY COMPLIANCE VALIDATION
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "COMPLIANCE ERROR: vpc_cidr must be a valid IPv4 CIDR block format (e.g., 10.0.0.0/16)."
  }
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

# -----------------------------------------------------------------------
# DYNAMIC INGRESS RULES: Each security group accepts a list of ingress
# rule objects. This enables flexible rule definitions without hardcoding.
# -----------------------------------------------------------------------
variable "bastion_ingress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed SSH access to Bastion Host (restrict in prod to office/vpn CIDRs)"

  # SECURITY AUDIT VALIDATION
  validation {
    condition     = length(var.bastion_ingress_cidrs) > 0 && alltrue([for cidr in var.bastion_ingress_cidrs : can(cidrnetmask(cidr))])
    error_message = "SECURITY COMPLIANCE ERROR: bastion_ingress_cidrs must be a non-empty list of valid IPv4 CIDR blocks."
  }
}

variable "app_ec2_ingress_ports" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
  description = "Dynamic ingress rules for Application EC2 security group"

  # RULE INTEGRITY VALIDATION
  validation {
    condition = alltrue([
      for rule in var.app_ec2_ingress_ports :
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535 &&
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "COMPLIANCE ERROR: app_ec2_ingress_ports must contain valid port ranges (0-65535) and valid protocols ('tcp', 'udp', 'icmp', '-1')."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
