# ==============================================================================
# AZURE SSL CERTIFICATE MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  module_tags = merge(
    var.tags,
    {
      Module      = "azure-ssl-certificate"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Security    = "KeyVault-RSA2048-TLS"
    }
  )

  primary_dns_name = var.dns_names[0]
}
