# ==============================================================================
# AZURE BLOB STORAGE MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "primary_blob_endpoint" {
  description = "Primary Blob Service Endpoint URL"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "container_name" {
  description = "Name of the private Blob Container"
  value       = azurerm_storage_container.private_container.name
}
