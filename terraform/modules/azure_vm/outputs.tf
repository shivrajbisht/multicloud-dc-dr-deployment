# ==============================================================================
# AZURE VM MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "vm_id" {
  description = "ID of the Azure Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the Azure Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip" {
  description = "Private IP address of the VM Network Interface"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "public_ip" {
  description = "Public IP address of the VM (if associated)"
  value       = var.associate_public_ip ? azurerm_public_ip.vm_pip[0].ip_address : null
}

output "nic_id" {
  description = "Resource ID of the Network Interface Card"
  value       = azurerm_network_interface.nic.id
}

output "ssh_private_key_pem" {
  description = "Generated RSA 4096 SSH Private Key PEM format"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key_openssh" {
  description = "Generated RSA 4096 SSH Public Key OpenSSH format"
  value       = tls_private_key.ssh_key.public_key_openssh
}
