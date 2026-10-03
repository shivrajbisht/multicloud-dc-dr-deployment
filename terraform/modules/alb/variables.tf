# ==============================================================================
# AWS APPLICATION LOAD BALANCER (ALB) MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "alb_name" {
  type        = string
  description = "Name of the Application Load Balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB and Target Group will be created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs across at least 2 AZs for ALB placement"
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
}

variable "target_port" {
  type        = number
  default     = 8080
  description = "Port on which target pods/instances listen"
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
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
