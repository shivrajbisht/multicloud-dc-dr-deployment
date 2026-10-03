# ==============================================================================
# KAFKA MIRRORMAKER 2 MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "kafka_namespace" {
  description = "Namespace where Kafka infrastructure and MM2 are deployed"
  value       = kubernetes_namespace.kafka_ns.metadata[0].name
}

output "strimzi_helm_status" {
  description = "Status of the Strimzi Operator Helm Release"
  value       = helm_release.strimzi_operator.status
}

output "mirrormaker2_name" {
  description = "Name of the MirrorMaker 2 custom resource instance"
  value       = kubernetes_manifest.kafka_mirrormaker2.manifest.metadata.name
}
