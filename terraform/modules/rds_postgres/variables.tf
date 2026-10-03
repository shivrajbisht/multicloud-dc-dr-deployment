# ==============================================================================
# AWS RDS POSTGRESQL 17 MODULE - VARIABLES DEFINITION
# ==============================================================================
# Configures a Multi-AZ PostgreSQL 17 database with AWS KMS Customer Managed Key
# (CMK) encryption at rest (EBS) and mandatory SSL/TLS encryption in transit.
# ==============================================================================

variable "identifier" {
  type        = string
  description = "Unique identifier name for the RDS PostgreSQL database instance"
}

variable "allocated_storage" {
  type        = number
  default     = 100
  description = "Allocated storage size in Gigabytes (gp3 SSD)"
}

variable "max_allocated_storage" {
  type        = number
  default     = 500
  description = "Maximum storage limit in GB for autoscaling"
}

variable "instance_class" {
  type        = string
  default     = "db.m6i.xlarge"
  description = "DB Instance class spec (e.g., db.m6i.xlarge)"
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "Initial database name to create"
}

variable "username" {
  type        = string
  default     = "dbadmin"
  description = "Master administrator username"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Master administrator password"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where database security group will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs across at least 3 Availability Zones for DB Subnet Group"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs permitted to connect to PostgreSQL (port 5432)"
}

variable "environment" {
  type        = string
  description = "Deployment target environment (dev, uat, prod)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all RDS resources"
}
