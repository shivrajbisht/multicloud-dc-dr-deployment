# ==============================================================================
# AZURE GITHUB OIDC MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "client_id" {
  description = "Client ID of the Azure User Assigned Identity used in GitHub Actions login"
  value       = azurerm_user_assigned_identity.identity.client_id
}

output "principal_id" {
  description = "Principal ID of the User Assigned Identity"
  value       = azurerm_user_assigned_identity.identity.principal_id
}
