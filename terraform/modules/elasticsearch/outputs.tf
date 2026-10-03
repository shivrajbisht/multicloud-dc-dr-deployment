# ==============================================================================
# ELASTICSEARCH MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "elasticsearch_namespace" {
  description = "Namespace where Elasticsearch operator and cluster are deployed"
  value       = kubernetes_namespace.elastic_ns.metadata[0].name
}

output "elasticsearch_cluster_name" {
  description = "Name of the Elasticsearch cluster resource"
  value       = kubernetes_manifest.elasticsearch_cluster.manifest.metadata.name
}

output "eck_operator_status" {
  description = "Helm release status for ECK Operator"
  value       = helm_release.eck_operator.status
}
