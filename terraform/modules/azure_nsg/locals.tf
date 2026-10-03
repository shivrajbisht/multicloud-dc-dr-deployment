# ==============================================================================
# AZURE NSG MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "azure-nsg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
