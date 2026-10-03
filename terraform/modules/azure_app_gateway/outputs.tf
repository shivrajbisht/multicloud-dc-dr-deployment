# ==============================================================================
# AZURE APPLICATION GATEWAY V2 MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "appgw_id" {
  description = "Resource ID of the Azure Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "public_ip_address" {
  description = "Public IP address allocated to Application Gateway Frontend"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "backend_address_pool_id" {
  description = "ID of the Application Gateway Backend Address Pool"
  value       = tolist(azurerm_application_gateway.appgw.backend_address_pool)[0].id
}

output "frontend_ip_configuration_id" {
  description = "ID of the Frontend IP Configuration"
  value       = tolist(azurerm_application_gateway.appgw.frontend_ip_configuration)[0].id
}
