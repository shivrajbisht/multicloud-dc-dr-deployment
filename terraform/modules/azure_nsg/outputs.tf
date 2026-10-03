# ==============================================================================
# AZURE NSG MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "bastion_nsg_id" {
  description = "NSG ID for Bastion Host subnet"
  value       = azurerm_network_security_group.bastion_nsg.id
}

output "app_vm_nsg_id" {
  description = "NSG ID for Application VM subnet"
  value       = azurerm_network_security_group.app_vm_nsg.id
}

output "aks_nsg_id" {
  description = "NSG ID for AKS Nodes subnet"
  value       = azurerm_network_security_group.aks_nsg.id
}

output "db_nsg_id" {
  description = "NSG ID for Database subnet"
  value       = azurerm_network_security_group.db_nsg.id
}
