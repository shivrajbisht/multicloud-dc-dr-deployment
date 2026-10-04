# ==============================================================================
# AWS APPLICATION LOAD BALANCER (ALB) MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "alb_name" {
  type        = string
  description = "Name of the Application Load Balancer"

  # NAME VALIDATION
  validation {
    condition     = length(var.alb_name) > 0 && length(var.alb_name) <= 32
    error_message = "COMPLIANCE ERROR: alb_name must be between 1 and 32 characters long."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB and Target Group will be created"

  # VPC ID VALIDATION
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "COMPLIANCE ERROR: vpc_id must be a valid AWS VPC ID starting with 'vpc-'."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs across at least 2 AZs for ALB placement"

  # HIGH AVAILABILITY SUBNET VALIDATION
  validation {
    condition     = length(var.public_subnet_ids) >= 2 && alltrue([for s in var.public_subnet_ids : can(regex("^subnet-[a-f0-9]{8,17}$", s))])
    error_message = "HIGH AVAILABILITY ERROR: ALB requires at least 2 public subnet IDs in distinct Availability Zones."
  }
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Optional additional security group IDs to attach to the ALB"
}

variable "target_type" {
  type        = string
  default     = "ip" # "ip" for EKS Pod IP routing via AWS Load Balancer Controller TargetGroupBinding, or "instance" for EC2
  description = "Target type for the target group (ip or instance)"

  # TARGET TYPE COMPLIANCE
  validation {
    condition     = contains(["ip", "instance", "alb", "lambda"], var.target_type)
    error_message = "COMPLIANCE ERROR: target_type must be one of ['ip', 'instance', 'alb', 'lambda']."
  }
}

variable "target_port" {
  type        = number
  default     = 8080
  description = "Port on which target pods/instances listen"

  # PORT RANGE VALIDATION
  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "COMPLIANCE ERROR: target_port must be between 1 and 65535."
  }
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ACM Certificate ARN for TLS/SSL termination on port 443"
}

variable "health_check_path" {
  type        = string
  default     = "/healthz"
  description = "HTTP path for target group health checks"
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
