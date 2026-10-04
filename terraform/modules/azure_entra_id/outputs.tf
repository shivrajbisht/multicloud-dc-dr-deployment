# ==============================================================================
# AZURE ENTRA ID MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "devops_admins_group_object_id" {
  description = "Object ID of the Entra ID DevOps Admins Group"
  value       = azuread_group.devops_admins.object_id
}

output "developers_group_object_id" {
  description = "Object ID of the Entra ID Developers Group"
  value       = azuread_group.developers.object_id
}

output "security_auditors_group_object_id" {
  description = "Object ID of the Entra ID Security Auditors Group"
  value       = azuread_group.auditors.object_id
}

output "service_principal_client_id" {
  description = "Client ID of the Automation Service Principal"
  value       = azuread_service_principal.automation_sp.client_id
}

output "service_principal_object_id" {
  description = "Object ID of the Automation Service Principal"
  value       = azuread_service_principal.automation_sp.object_id
}
