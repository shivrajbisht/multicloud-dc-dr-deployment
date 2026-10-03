# ==============================================================================
# AZURE VM MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  vm_full_name = "${var.vm_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Name        = local.vm_full_name
      Module      = "azure-vm"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
