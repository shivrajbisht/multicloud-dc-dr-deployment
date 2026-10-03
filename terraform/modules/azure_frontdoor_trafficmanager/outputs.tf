# ==============================================================================
# AZURE FRONT DOOR & TRAFFIC MANAGER MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "frontdoor_hostname" {
  description = "Domain name of the Azure Front Door Endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}

output "traffic_manager_fqdn" {
  description = "FQDN of the Azure Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.tm_profile.fqdn
}
