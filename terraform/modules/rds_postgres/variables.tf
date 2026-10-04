# ==============================================================================
# AWS RDS POSTGRESQL 17 MODULE - VARIABLES DEFINITION (WITH VALIDATIONS & SENSITIVE FLAGS)
# ==============================================================================

variable "identifier" {
  type        = string
  description = "Unique identifier name for the RDS PostgreSQL database instance"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.identifier))
    error_message = "RDS IDENTIFIER ERROR: identifier must consist of lowercase alphanumeric characters or hyphens (3-63 chars)."
  }
}

variable "allocated_storage" {
  type        = number
  default     = 100
  description = "Allocated storage size in Gigabytes (gp3 SSD)"

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "STORAGE VALIDATION ERROR: allocated_storage must be between 20 GB and 65536 GB."
  }
}

variable "max_allocated_storage" {
  type        = number
  default     = 500
  description = "Maximum storage limit in GB for autoscaling"

  validation {
    condition     = var.max_allocated_storage >= var.allocated_storage
    error_message = "AUTOSCALING ERROR: max_allocated_storage must be greater than or equal to allocated_storage."
  }
}

variable "instance_class" {
  type        = string
  default     = "db.m6i.xlarge"
  description = "DB Instance class spec (e.g., db.m6i.xlarge, db.r6i.xlarge, db.t4g.medium)"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "INSTANCE CLASS ERROR: instance_class must follow standard AWS RDS naming (e.g. db.m6i.xlarge)."
  }
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "Initial database name to create"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]{1,63}$", var.db_name))
    error_message = "DB NAME ERROR: db_name must contain 1-63 alphanumeric characters or underscores."
  }
}

variable "username" {
  type        = string
  default     = "dbadmin"
  description = "Master administrator username"
  sensitive   = true # SENSITIVE CREDENTIAL MASKED FROM CLI OUTPUT

  validation {
    condition     = length(var.username) >= 4 && !contains(["admin", "postgres", "root"], var.username)
    error_message = "SECURITY COMPLIANCE ERROR: Master username cannot be generic ('admin', 'postgres', 'root') and must be at least 4 characters."
  }
}

variable "password" {
  type        = string
  sensitive   = true # SENSITIVE CREDENTIAL MASKED FROM LOGS & TF STATE OUTPUT

  validation {
    condition     = length(var.password) >= 12 && can(regex("[A-Z]", var.password)) && can(regex("[a-z]", var.password)) && can(regex("[0-9]", var.password))
    error_message = "PASSWORD COMPLEXITY ERROR: Master password must be at least 12 characters and contain uppercase, lowercase, and numeric characters."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where database security group will be created"

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID ERROR: vpc_id must be a valid AWS VPC ID string starting with 'vpc-'."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs across at least 3 Availability Zones for DB Subnet Group"

  validation {
    condition     = length(var.subnet_ids) >= 2 && alltrue([for s in var.subnet_ids : can(regex("^subnet-[a-f0-9]+$", s))])
    error_message = "HA SUBNET ERROR: subnet_ids must contain at least 2 valid subnet IDs starting with 'subnet-' for Multi-AZ placement."
  }
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs permitted to connect to PostgreSQL (port 5432)"

  validation {
    condition     = alltrue([for sg in var.allowed_security_group_ids : can(regex("^sg-[a-f0-9]+$", sg))])
    error_message = "SECURITY GROUP ERROR: Every entry in allowed_security_group_ids must be a valid AWS Security Group ID starting with 'sg-'."
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
  description = "Tags applied to all RDS resources"
}
