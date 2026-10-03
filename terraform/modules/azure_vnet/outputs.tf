# ==============================================================================
# AZURE VNET MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "vnet_id" {
  description = "Resource ID of the Azure Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Azure Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_ids" {
  description = "IDs of the 3 public subnets"
  value       = azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the 3 private subnets"
  value       = azurerm_subnet.private[*].id
}

output "aks_subnet_id" {
  description = "ID of the AKS dedicated subnet"
  value       = azurerm_subnet.aks.id
}

output "nat_gateway_id" {
  description = "Resource ID of the NAT Gateway"
  value       = azurerm_nat_gateway.nat.id
}
