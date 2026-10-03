# ==============================================================================
# ELASTICSEARCH DC-DR REPLICATION TERRAFORM MODULE
# ==============================================================================
# Provisions ECK (Elastic Cloud on Kubernetes) Operator via Helm and builds an
# enterprise Elasticsearch cluster configured for Cross-Cluster Replication (CCR).
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
# 1. KUBERNETES NAMESPACE FOR ELASTICSEARCH SYSTEM
# ------------------------------------------------------------------------------

resource "kubernetes_namespace" "elastic_ns" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
      "component"                    = "elasticsearch-dc-dr"
    }
  }
}

# ------------------------------------------------------------------------------
# 2. HELM RELEASE: ECK OPERATOR (ELASTIC CLOUD ON KUBERNETES)
# ------------------------------------------------------------------------------

resource "helm_release" "eck_operator" {
  name             = "eck-operator"
  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  version          = "2.11.0"
  namespace        = kubernetes_namespace.elastic_ns.metadata[0].name
  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ------------------------------------------------------------------------------
# 3. ELASTICSEARCH CLUSTER MANIFEST WITH CROSS-CLUSTER REPLICATION (CCR)
# ------------------------------------------------------------------------------

resource "kubernetes_manifest" "elasticsearch_cluster" {
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/1"
    kind       = "Elasticsearch"
    metadata = {
      name      = var.cluster_name
      namespace = kubernetes_namespace.elastic_ns.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "elasticsearch"
        "app.kubernetes.io/component"  = "dc-dr-datastore"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      version = var.es_version
      nodeSets = [
        {
          name     = "default"
          count    = var.node_count
          config = {
            "node.store.allow_mmap"            = false
            "cluster.remote.dr-remote-cluster.seeds" = ["dr-elasticsearch-es-transport.elastic-system.svc:9300"]
          }
          podTemplate = {
            spec = {
              containers = [
                {
                  name = "elasticsearch"
                  resources = {
                    limits = {
                      memory = "4Gi"
                      cpu    = "2"
                    }
                    requests = {
                      memory = "2Gi"
                      cpu    = "1"
                    }
                  }
                }
              ]
            }
          }
          volumeClaimTemplates = [
            {
              metadata = {
                name = "elasticsearch-data"
              }
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.storage_size
                  }
                }
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.eck_operator]
}
