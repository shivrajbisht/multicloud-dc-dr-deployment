# ==============================================================================
# AZURE POSTGRESQL FLEXIBLE SERVER MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.postgres.id
}

output "fqdn" {
  description = "Fully Qualified Domain Name of the server"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "identity_principal_id" {
  description = "Principal ID of the User Assigned Identity"
  value       = azurerm_user_assigned_identity.pg_identity.principal_id
}
