# ==============================================================================
# AZURE AKS MODULE - OUTPUTS DEFINITION
# ==============================================================================
# Exports key outputs for AKS cluster administration and GitOps integration.
# ==============================================================================

output "cluster_id" {
  description = "Resource ID of the created AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig file content for cluster access"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL used for Azure Workload Identity federation"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "user_identity_id" {
  description = "Client ID of the User Assigned Identity created for AKS"
  value       = azurerm_user_assigned_identity.aks_identity.client_id
}

output "spot_node_pool_id" {
  description = "ID of the Spot Scale Set User Node Pool"
  value       = azurerm_kubernetes_cluster_node_pool.spot_user_pool.id
}

output "ondemand_node_pool_id" {
  description = "ID of the On-Demand Scale Set User Node Pool"
  value       = azurerm_kubernetes_cluster_node_pool.ondemand_user_pool.id
}
