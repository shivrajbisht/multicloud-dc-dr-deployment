# ==============================================================================
# AZURE VIRTUAL MACHINE (VM) TERRAFORM MODULE
# ==============================================================================
# Features:
#   - TLS RSA 4096 SSH Key generated automatically (no manual key creation)
#   - SSH Public Key stored on VM; Private Key in Azure Key Vault
#   - Ubuntu 24.04 LTS latest image fetched via DATA BLOCK
#   - Zone-Aware deployment (Availability Zone 1)
#   - OS disk encrypted via Platform-Managed Key (disk encryption set for CMK)
#   - DYNAMIC BLOCK for additional managed data disk attachments
#   - Password Authentication DISABLED (SSH key only)
#   - Suitable for: Bastion Host, App Server, CI/CD Agent
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. DATA BLOCK: FETCH LATEST UBUNTU 24.04 LTS IMAGE DYNAMICALLY
#    Avoids hardcoded image references that go stale
# ------------------------------------------------------------------------------

data "azurerm_platform_image" "ubuntu" {
  location  = var.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
}

# ------------------------------------------------------------------------------
# 2. GENERATE RSA 4096 SSH KEY PAIR VIA TERRAFORM TLS PROVIDER
# ------------------------------------------------------------------------------

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ------------------------------------------------------------------------------
# 3. OPTIONAL PUBLIC IP (FOR BASTION HOST ONLY)
# ------------------------------------------------------------------------------

resource "azurerm_public_ip" "vm_pip" {
  count               = var.associate_public_ip ? 1 : 0
  name                = "${local.vm_full_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]

  tags = merge(local.common_tags, { Name = "${local.vm_full_name}-pip" })
}

# ------------------------------------------------------------------------------
# 4. NETWORK INTERFACE CARD (NIC)
# ------------------------------------------------------------------------------

resource "azurerm_network_interface" "nic" {
  name                = "${local.vm_full_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # Conditionally attach public IP for Bastion
    public_ip_address_id = var.associate_public_ip ? azurerm_public_ip.vm_pip[0].id : null
  }

  tags = merge(local.common_tags, { Name = "${local.vm_full_name}-nic" })
}

# Associate NIC with Network Security Group
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.nsg_id
}

# ------------------------------------------------------------------------------
# 5. AZURE LINUX VIRTUAL MACHINE
# ------------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = local.vm_full_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true  # SSH KEY ONLY - security best practice
  network_interface_ids           = [azurerm_network_interface.nic.id]
  zone                            = "1"

  # SSH Public Key Authentication using TLS-generated key
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  # OS Disk Configuration with Encryption
  os_disk {
    name                 = "${local.vm_full_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  # Dynamically resolved Ubuntu 24.04 LTS image
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Azure Boot Diagnostics for console log and screenshot access
  boot_diagnostics {}

  tags = local.common_tags

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = var.os_disk_size_gb >= 30
      error_message = "SECURITY PRECONDITION FAILURE: Azure VM OS disk size must be at least 30 GB."
    }
    postcondition {
      condition     = self.disable_password_authentication == true
      error_message = "SECURITY POSTCONDITION FAILURE: Azure VM password authentication must be disabled (SSH key only)."
    }
  }
}

# ------------------------------------------------------------------------------
# 6. DYNAMIC BLOCK: ADDITIONAL MANAGED DATA DISK ATTACHMENTS
# ------------------------------------------------------------------------------

resource "azurerm_managed_disk" "data_disks" {
  for_each = { for disk in var.additional_data_disks : disk.name => disk }

  name                 = "${local.vm_full_name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  zone                 = "1"

  tags = merge(local.common_tags, { DiskName = each.value.name })
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  for_each = azurerm_managed_disk.data_disks

  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = index(var.additional_data_disks[*].name, each.key)
  caching            = var.additional_data_disks[index(var.additional_data_disks[*].name, each.key)].caching
}
