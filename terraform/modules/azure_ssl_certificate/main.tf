# ==============================================================================
# AZURE KEY VAULT SSL CERTIFICATE TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Automated RSA 2048-bit Key Pair & PKCS12 Certificate Generation in Key Vault
#   - Dynamic blocks for Subject Alternative Names (SANs)
#   - Data blocks for Azure Client Config lookup
#   - Local values for Tag Standardization
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
# 1. DATA BLOCK: CURRENT AZURE CLIENT & TENANT METADATA LOOKUP
# ------------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------
# 2. AZURE KEY VAULT CERTIFICATE PROVISIONING (DYNAMIC BLOCKS & LOCALS)
# ------------------------------------------------------------------------------

resource "azurerm_key_vault_certificate" "ssl_cert" {
  name         = var.certificate_name
  key_vault_id = var.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self" # Self-signed or Integrated Certificate Authority (DigiCert/GlobalSign)
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"] # Server Authentication

      # Dynamic block building Subject Alternative Names (SANs)
      dynamic "subject_alternative_names" {
        for_each = length(var.dns_names) > 0 ? [1] : []
        content {
          dns_names = var.dns_names
        }
      }

      subject    = "CN=${local.primary_dns_name}"
      validity_in_months = 12
    }
  }

  tags = merge(
    local.module_tags,
    {
      Name = var.certificate_name
    }
  )
}
