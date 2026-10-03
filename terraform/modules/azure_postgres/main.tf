# ==============================================================================
# AZURE POSTGRESQL FLEXIBLE SERVER TERRAFORM MODULE
# ==============================================================================
# Features:
#   - High Availability: Zone-Redundant HA across Availability Zones
#   - 100% Encryption at Rest: Azure Key Vault Customer Managed Key (CMK)
#   - 100% Encryption in Transit: Enforced TLS 1.2+ (require_secure_transport = true)
#   - Private VNet Subnet Delegation
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
# 1. USER ASSIGNED MANAGED IDENTITY FOR KEY VAULT CMK ACCESS
# ------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "pg_identity" {
  name                = "${var.server_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name        = "${var.server_name}-identity"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AZURE POSTGRESQL FLEXIBLE SERVER (ZONE-REDUNDANT HA & CMK ENCRYPTION)
# ------------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "16" # PostgreSQL 16/17 Flexible Server
  delegated_subnet_id    = var.subnet_id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  sku_name   = "GP_Standard_D4ds_v5"
  storage_mb = 131072 # 128 GB SSD

  # --- HIGH AVAILABILITY (ZONE REDUNDANT ACROSS AZ 1 & 2) ---
  high_availability {
    mode                    = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  zone = "1"

  # --- ENCRYPTION AT REST VIA AZURE KEY VAULT CMK ---
  customer_managed_key {
    key_vault_key_id                  = var.key_vault_key_id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.pg_identity.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.pg_identity.id]
  }

  # Backup retention and geo-redundancy settings
  backup_retention_days        = 30
  geo_redundant_backup_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = var.server_name
      Engine      = "PostgreSQL-Flexible"
      Environment = var.environment
      Security    = "CMK-Encrypted-TLS-Enforced"
    }
  )

  lifecycle {
    ignore_changes = [
      administrator_password,
      zone
    ]
  }
}

# ------------------------------------------------------------------------------
# 3. ENFORCE MANDATORY TLS 1.2+ IN-TRANSIT CONFIGURATION PARAMETER
# ------------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_configuration" "enforce_tls" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "on"
}
