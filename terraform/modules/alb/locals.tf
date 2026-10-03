# ==============================================================================
# AWS ALB MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "AWS-ALB"
    }
  )
}
