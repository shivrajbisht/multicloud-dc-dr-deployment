# ==============================================================================
# ELASTICSEARCH MODULE - VARIABLES DEFINITION
# ==============================================================================
# Configuration inputs for ECK (Elastic Cloud on Kubernetes) deployment
# with Cross-Cluster Replication (CCR) support across EKS (DC) and AKS (DR).
# ==============================================================================

variable "namespace" {
  type        = string
  default     = "elastic-system"
  description = "Kubernetes namespace for Elasticsearch Operator and Cluster"
}

variable "cluster_name" {
  type        = string
  default     = "multicloud-es-cluster"
  description = "Name of the Elasticsearch cluster instance"
}

variable "es_version" {
  type        = string
  default     = "8.12.0"
  description = "Elasticsearch version to deploy"
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of master/data nodes in the Elasticsearch cluster"
}

variable "storage_size" {
  type        = string
  default     = "100Gi"
  description = "Persistent Volume disk allocation size per Elasticsearch node"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, uat, prod)"
}
