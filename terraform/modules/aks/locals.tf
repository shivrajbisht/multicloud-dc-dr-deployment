# ==============================================================================
# AZURE AKS MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "azure-aks"
      Kubernetes  = var.kubernetes_version
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # Scoped identity prefix
  identity_name = "${var.cluster_name}-identity"
}
