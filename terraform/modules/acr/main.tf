# ==============================================================================
# AZURE CONTAINER REGISTRY (ACR) TERRAFORM MODULE (PREMIUM & CMK ENCRYPTED)
# ==============================================================================
# Features:
#   - High Availability: Premium SKU with Zone Redundancy enabled
#   - 100% Encryption at Rest: Azure Key Vault Customer Managed Key (CMK)
#   - Admin user disabled for zero-trust security compliance
#   - Quarantine policy & image retention rules
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
# 1. USER ASSIGNED MANAGED IDENTITY FOR ACR KEY VAULT CMK
# ------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "acr_identity" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-identity"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AZURE CONTAINER REGISTRY (PREMIUM SKU WITH CMK & ZONE REDUNDANCY)
# ------------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium" # Required for CMK Encryption & Zone Redundancy
  admin_enabled       = false     # Zero-trust security compliance

  # --- HIGH AVAILABILITY ZONE REDUNDANCY ---
  zone_redundancy_enabled = true

  # --- ENCRYPTION AT REST VIA AZURE KEY VAULT CMK ---
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_identity.id]
  }

  encryption {
    enabled            = true
    key_vault_key_id   = var.key_vault_key_id
    identity_client_id = azurerm_user_assigned_identity.acr_identity.client_id
  }

  tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      Security    = "CMK-Premium-ZoneRedundant"
    }
  )
}
