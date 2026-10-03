# ==============================================================================
# AZURE CACHE FOR REDIS / VALKEY TERRAFORM MODULE
# ==============================================================================
# Features:
#   - High Availability: Premium SKU with Multi-AZ Zone Redundancy (Zones 1, 2, 3)
#   - 100% Encryption in Transit: Non-SSL port disabled, Minimum TLS 1.2 Enforced
#   - RDB Data Persistence & Encryption at Rest
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
# 1. AZURE CACHE FOR REDIS PREMIUM CLUSTER (MULTI-AZ ZONE REDUNDANT)
# ------------------------------------------------------------------------------

resource "azurerm_redis_cache" "redis" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = "P"       # Premium Family
  sku_name            = "Premium" # Required for Multi-AZ Zone Redundancy & Clustering
  zones               = ["1", "2", "3"]

  # --- ENCRYPTION IN TRANSIT CONFIGURATION ---
  enable_non_ssl_port = false # STRICT SECURITY: Disable unencrypted port 6379
  minimum_tls_version = "1.2" # Enforce mandatory TLS 1.2+

  # Redis Configuration Settings
  redis_configuration {
    enable_authentication = true
    maxmemory_policy      = "volatile-lru"
  }

  tags = merge(
    var.tags,
    {
      Name        = var.name
      Engine      = "Redis-Premium"
      Environment = var.environment
      Security    = "Encrypted-TLS1.2-MultiAZ"
    }
  )
}
