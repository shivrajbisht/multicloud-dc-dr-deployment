# ==============================================================================
# AWS SECURITY GROUPS MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "aws-security-groups"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
