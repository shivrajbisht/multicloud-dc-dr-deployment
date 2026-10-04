# ==============================================================================
# ELASTICSEARCH MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "namespace" {
  type        = string
  default     = "elastic-system"
  description = "Kubernetes namespace for Elasticsearch Operator and Cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.namespace))
    error_message = "NAMESPACE ERROR: namespace must be a valid Kubernetes namespace name."
  }
}

variable "cluster_name" {
  type        = string
  default     = "multicloud-es-cluster"
  description = "Name of the Elasticsearch cluster instance"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.cluster_name))
    error_message = "CLUSTER NAME ERROR: cluster_name must contain 1-63 lowercase alphanumeric characters or hyphens."
  }
}

variable "es_version" {
  type        = string
  default     = "8.12.0"
  description = "Elasticsearch version to deploy"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.es_version))
    error_message = "ES VERSION ERROR: es_version must be a valid semver version string (e.g. 8.12.0)."
  }
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of master/data nodes in the Elasticsearch cluster"

  validation {
    condition     = var.node_count >= 3
    error_message = "HA ERROR: node_count must be at least 3 nodes for master quorum HA."
  }
}

variable "storage_size" {
  type        = string
  default     = "100Gi"
  description = "Persistent Volume disk allocation size per Elasticsearch node"

  validation {
    condition     = can(regex("^[0-9]+(Gi|Mi|Ti)$", var.storage_size))
    error_message = "STORAGE SIZE ERROR: storage_size must be a valid Kubernetes quantity (e.g. 100Gi)."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, staging, prod)"

  validation {
    condition     = contains(["dev", "uat", "staging", "prod"], var.environment)
    error_message = "ENVIRONMENT ERROR: environment must be one of: 'dev', 'uat', 'staging', 'prod'."
  }
}
