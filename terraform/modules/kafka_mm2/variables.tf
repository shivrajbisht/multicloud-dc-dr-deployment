# ==============================================================================
# KAFKA MIRRORMAKER 2 (MM2) MODULE - VARIABLES DEFINITION (WITH VALIDATIONS)
# ==============================================================================

variable "namespace" {
  type        = string
  default     = "kafka-system"
  description = "Kubernetes namespace where Strimzi Operator and MM2 will be installed"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.namespace))
    error_message = "NAMESPACE ERROR: namespace must be a valid Kubernetes namespace name."
  }
}

variable "release_name" {
  type        = string
  default     = "strimzi-kafka-operator"
  description = "Helm release name for the Strimzi Kafka operator"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.release_name))
    error_message = "RELEASE NAME ERROR: release_name must contain lowercase alphanumeric characters or hyphens."
  }
}

variable "strimzi_chart_version" {
  type        = string
  default     = "0.40.0"
  description = "Strimzi Helm chart version"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.strimzi_chart_version))
    error_message = "CHART VERSION ERROR: strimzi_chart_version must be a valid semver version (e.g. 0.40.0)."
  }
}

variable "dc_cluster_bootstrap_server" {
  type        = string
  description = "Kafka Bootstrap server URL for Data Center (EKS Cluster)"

  validation {
    condition     = length(var.dc_cluster_bootstrap_server) > 0
    error_message = "BOOTSTRAP SERVER ERROR: dc_cluster_bootstrap_server cannot be empty."
  }
}

variable "dr_cluster_bootstrap_server" {
  type        = string
  description = "Kafka Bootstrap server URL for Disaster Recovery (AKS Cluster)"

  validation {
    condition     = length(var.dr_cluster_bootstrap_server) > 0
    error_message = "BOOTSTRAP SERVER ERROR: dr_cluster_bootstrap_server cannot be empty."
  }
}

variable "replication_topics_pattern" {
  type        = string
  default     = "order-.*|payment-.*|user-.*"
  description = "Regex pattern matching Kafka topics to replicate across DC and DR"

  validation {
    condition     = length(var.replication_topics_pattern) > 0
    error_message = "TOPICS PATTERN ERROR: replication_topics_pattern cannot be empty."
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
