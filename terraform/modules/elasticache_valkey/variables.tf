# ==============================================================================
# ELASTICACHE VALKEY MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "replication_group_id" {
  type        = string
  description = "Identifier for the ElastiCache Valkey replication group"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,40}$", var.replication_group_id))
    error_message = "REPLICATION GROUP ID ERROR: replication_group_id must contain 1-40 lowercase alphanumeric characters or hyphens."
  }
}

variable "node_type" {
  type        = string
  default     = "cache.m6g.large"
  description = "Compute node instance type for Valkey cache cluster"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9.]+$", var.node_type))
    error_message = "NODE TYPE ERROR: node_type must be a valid AWS ElastiCache node type starting with 'cache.'."
  }
}

variable "num_node_groups" {
  type        = number
  default     = 2
  description = "Number of shards (node groups) for cluster mode enabled"

  validation {
    condition     = var.num_node_groups >= 1 && var.num_node_groups <= 50
    error_message = "SHARD COUNT ERROR: num_node_groups must be between 1 and 50."
  }
}

variable "replicas_per_node_group" {
  type        = number
  default     = 2
  description = "Number of replica nodes per shard across Multi-AZ"

  validation {
    condition     = var.replicas_per_node_group >= 1 && var.replicas_per_node_group <= 5
    error_message = "REPLICA COUNT ERROR: replicas_per_node_group must be between 1 and 5."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID housing the cache subnet group"

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID ERROR: vpc_id must be a valid AWS VPC ID starting with 'vpc-'."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs across 3 Availability Zones"

  validation {
    condition     = length(var.subnet_ids) >= 2 && alltrue([for s in var.subnet_ids : can(regex("^subnet-[a-f0-9]+$", s))])
    error_message = "SUBNET ERROR: subnet_ids must contain at least 2 valid subnet IDs starting with 'subnet-'."
  }
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of application security group IDs allowed to access Valkey cache (port 6379)"
}

variable "auth_token" {
  type        = string
  sensitive   = true
  description = "AUTH token / password for TLS authenticated access"

  validation {
    condition     = length(var.auth_token) >= 16
    error_message = "SECURITY ERROR: auth_token must be at least 16 characters for ElastiCache authentication."
  }
}

variable "environment" {
  type        = string
  description = "Deployment target environment (dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags applied to ElastiCache Valkey infrastructure"
}
