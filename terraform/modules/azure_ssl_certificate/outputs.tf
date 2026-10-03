# ==============================================================================
# AZURE SSL CERTIFICATE MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "certificate_id" {
  description = "Key Vault Certificate Resource ID"
  value       = azurerm_key_vault_certificate.ssl_cert.id
}

output "certificate_secret_id" {
  description = "Secret ID used by Azure App Service / Gateway to retrieve the PFX certificate"
  value       = azurerm_key_vault_certificate.ssl_cert.secret_id
}
