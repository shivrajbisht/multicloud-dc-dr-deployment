# ==============================================================================
# AZURE BLOB STORAGE TERRAFORM MODULE (CMK & TLS 1.2+ ENFORCED)
# ==============================================================================
# Features:
#   - High Availability: Geo-Zone-Redundant Storage (GZRS - Multi-AZ + Geo Replication)
#   - 100% Encryption at Rest: Azure Key Vault Customer Managed Key (CMK)
#   - 100% Encryption in Transit: HTTPS Only Enforced, Minimum TLS 1.2
#   - Public Access Blocked
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
# 1. USER ASSIGNED MANAGED IDENTITY FOR KEY VAULT ACCESS
# ------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "${var.storage_account_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name        = "${var.storage_account_name}-identity"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AZURE STORAGE ACCOUNT (GEO-ZONE-REDUNDANT & HTTPS ENFORCED)
# ------------------------------------------------------------------------------

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "GZRS" # Geo-Zone-Redundant Storage across AZs

  # --- ENCRYPTION IN TRANSIT CONFIGURATION ---
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  # Disable public blob access for security compliance
  allow_nested_items_to_be_public = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_identity.id]
  }

  tags = merge(
    var.tags,
    {
      Name        = var.storage_account_name
      Environment = var.environment
      Security    = "CMK-GZRS-Encrypted"
    }
  )

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
      error_message = "PRECONDITION FAILURE: storage_account_name length must be between 3 and 24 characters."
    }
    postcondition {
      condition     = self.enable_https_traffic_only == true && self.allow_nested_items_to_be_public == false
      error_message = "SECURITY POSTCONDITION FAILURE: HTTPS traffic only must be enabled and public blob access disabled."
    }
  }
}

# ------------------------------------------------------------------------------
# 3. CUSTOMER MANAGED KEY (CMK) ENCRYPTION AT REST VIA KEY VAULT
# ------------------------------------------------------------------------------

resource "azurerm_storage_account_customer_managed_key" "storage_cmk" {
  storage_account_id = azurerm_storage_account.storage.id
  key_vault_id       = split("/keys/", var.key_vault_key_id)[0]
  key_name           = split("/keys/", var.key_vault_key_id)[1]
  user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id
}

# ------------------------------------------------------------------------------
# 4. PRIVATE BLOB CONTAINER PROVISIONING
# ------------------------------------------------------------------------------

resource "azurerm_storage_container" "private_container" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private" # Strict private access
}
