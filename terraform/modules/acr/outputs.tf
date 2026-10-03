# ==============================================================================
# AZURE CONTAINER REGISTRY (ACR) MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "id" {
  description = "Resource ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "login_server" {
  description = "Login Server URL for container docker push/pull operations"
  value       = azurerm_container_registry.acr.login_server
}
