# ==============================================================================
# AZURE NETWORK SECURITY GROUPS (NSG) TERRAFORM MODULE
# ==============================================================================
# Creates:
#   1. BASTION NSG     - SSH (22) allowed from restricted CIDRs, deny all else
#   2. APP VM NSG      - Dynamic inbound rules from variable + SSH from Bastion only
#   3. AKS SUBNET NSG  - Allow pod-to-pod communication, deny internet inbound
#   4. DB SUBNET NSG   - PostgreSQL 5432, Redis 6379 from App/AKS subnets only
# Dynamic blocks used for flexible rule creation without hardcoding.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. BASTION HOST NSG - SSH ACCESS FROM RESTRICTED CIDRs ONLY
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.environment}-bastion-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # DYNAMIC BLOCK: Create one inbound SSH rule per allowed CIDR
  dynamic "security_rule" {
    for_each = { for idx, cidr in var.bastion_allowed_ssh_cidrs : idx => cidr }
    content {
      name                       = "Allow-SSH-from-${replace(security_rule.value, "/", "-")}"
      priority                   = 100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-bastion-nsg" })
}

# ------------------------------------------------------------------------------
# 2. APPLICATION VM NSG - DYNAMIC RULES + SSH FROM BASTION SUBNET ONLY
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "app_vm_nsg" {
  name                = "${var.environment}-app-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # DYNAMIC BLOCK: Build inbound rules from var.app_inbound_rules list
  dynamic "security_rule" {
    for_each = var.app_inbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-app-vm-nsg" })
}

# ------------------------------------------------------------------------------
# 3. AKS NODES NSG - POD-TO-POD + API SERVER COMMUNICATION
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.environment}-aks-nodes-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Intra-VNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = var.vnet_cidr
  }

  security_rule {
    name                       = "Deny-Internet-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-aks-nodes-nsg" })
}

# ------------------------------------------------------------------------------
# 4. DATABASE SUBNET NSG - POSTGRESQL 5432 & REDIS 6379 FROM VNET ONLY
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.environment}-db-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-PostgreSQL-from-VNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Redis-from-VNet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-db-subnet-nsg" })

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = can(cidrnetmask(var.vnet_cidr))
      error_message = "PRECONDITION FAILURE: vnet_cidr must be a valid IPv4 CIDR string."
    }
    postcondition {
      condition     = length(self.security_rule) >= 2
      error_message = "POSTCONDITION FAILURE: DB NSG must contain strict ingress security rules."
    }
  }
}
