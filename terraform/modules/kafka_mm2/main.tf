# ==============================================================================
# KAFKA MIRRORMAKER 2 (MM2) DC-DR REPLICATION TERRAFORM MODULE
# ==============================================================================
# This module installs the Strimzi Kafka Operator via Helm and configures
# Kafka MirrorMaker 2 (MM2) for active-passive or active-active cross-cloud
# topic replication between Primary DC (AWS EKS) and Secondary DR (Azure AKS).
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. KUBERNETES NAMESPACE FOR KAFKA INFRASTRUCTURE
# ------------------------------------------------------------------------------

resource "kubernetes_namespace" "kafka_ns" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
      "component"                    = "kafka-dc-dr-replication"
    }
  }
}

# ------------------------------------------------------------------------------
# 2. HELM RELEASE: STRIMZI KAFKA OPERATOR
# ------------------------------------------------------------------------------

resource "helm_release" "strimzi_operator" {
  name             = var.release_name
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  version          = var.strimzi_chart_version
  namespace        = kubernetes_namespace.kafka_ns.metadata[0].name
  create_namespace = false

  set {
    name  = "watchAnyNamespace"
    value = "true"
  }
}

# ------------------------------------------------------------------------------
# 3. KAFKA MIRRORMAKER 2 (MM2) CUSTOM RESOURCE FOR DC-DR SYNC
# ------------------------------------------------------------------------------

resource "kubernetes_manifest" "kafka_mirrormaker2" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaMirrorMaker2"
    metadata = {
      name      = "dc-to-dr-mirrormaker2"
      namespace = kubernetes_namespace.kafka_ns.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "kafka-mm2"
        "app.kubernetes.io/component"  = "dc-dr-sync"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      version   = "3.6.0"
      replicas  = 3
      connectCluster = "dr-cluster"
      clusters = [
        {
          alias        = "dc-cluster"
          bootstrapServers = var.dc_cluster_bootstrap_server
          tls = {
            trustedCertificates = []
          }
        },
        {
          alias        = "dr-cluster"
          bootstrapServers = var.dr_cluster_bootstrap_server
          tls = {
            trustedCertificates = []
          }
        }
      ]
      mirrors = [
        {
          sourceCluster = "dc-cluster"
          targetCluster = "dr-cluster"
          sourceConnector = {
            tasksMax = 5
            config = {
              "replication.factor"        = "3"
              "offset-syncs.topic.replication.factor" = "3"
              "sync.topic.acls"           = "true"
              "refresh.topics.interval.seconds" = "10"
            }
          }
          checkpointConnector = {
            tasksMax = 2
            config = {
              "checkpoints.topic.replication.factor" = "3"
              "refresh.groups.interval.seconds"      = "10"
              "sync.group.offsets.enabled"           = "true"
            }
          }
          topicsPattern = var.replication_topics_pattern
          groupsPattern = ".*"
        }
      ]
    }
  }

  depends_on = [helm_release.strimzi_operator]
}
