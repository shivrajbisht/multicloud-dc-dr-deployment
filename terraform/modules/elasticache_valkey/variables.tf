# ==============================================================================
# ELASTICACHE VALKEY MODULE - VARIABLES DEFINITION
# ==============================================================================
# Configures Amazon ElastiCache Valkey / Redis with KMS CMK Encryption at Rest
# and Mandatory TLS Encryption in Transit across Multi-AZ subnets.
# ==============================================================================

variable "replication_group_id" {
  type        = string
  description = "Identifier for the ElastiCache Valkey replication group"
}

variable "node_type" {
  type        = string
  default     = "cache.m6g.large"
  description = "Compute node instance type for Valkey cache cluster"
}

variable "num_node_groups" {
  type        = number
  default     = 2
  description = "Number of shards (node groups) for cluster mode enabled"
}

variable "replicas_per_node_group" {
  type        = number
  default     = 2
  description = "Number of replica nodes per shard across Multi-AZ"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID housing the cache subnet group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs across 3 Availability Zones"
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
}

variable "environment" {
  type        = string
  description = "Deployment target environment (dev, uat, prod)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags applied to ElastiCache Valkey infrastructure"
}
