# ==============================================================================
# KAFKA MIRRORMAKER 2 (MM2) MODULE - VARIABLES DEFINITION
# ==============================================================================
# Configuration parameters for Strimzi Kafka Operator & MirrorMaker 2
# deployed across AWS EKS (DC) and Azure AKS (DR) for cross-cloud streaming sync.
# ==============================================================================

variable "namespace" {
  type        = string
  default     = "kafka-system"
  description = "Kubernetes namespace where Strimzi Operator and MM2 will be installed"
}

variable "release_name" {
  type        = string
  default     = "strimzi-kafka-operator"
  description = "Helm release name for the Strimzi Kafka operator"
}

variable "strimzi_chart_version" {
  type        = string
  default     = "0.40.0"
  description = "Strimzi Helm chart version"
}

variable "dc_cluster_bootstrap_server" {
  type        = string
  description = "Kafka Bootstrap server URL for Data Center (EKS Cluster)"
}

variable "dr_cluster_bootstrap_server" {
  type        = string
  description = "Kafka Bootstrap server URL for Disaster Recovery (AKS Cluster)"
}

variable "replication_topics_pattern" {
  type        = string
  default     = "order-.*|payment-.*|user-.*"
  description = "Regex pattern matching Kafka topics to replicate across DC and DR"
}

variable "environment" {
  type        = string
  description = "Deployment target environment (dev, uat, prod)"
}
