# ==============================================================================
# ENVIRONMENT: DEV - LOCALS DEFINITION
# ==============================================================================

locals {
  environment = var.environment
  project     = "multicloud-dc-dr"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}
