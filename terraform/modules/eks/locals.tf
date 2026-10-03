# ==============================================================================
# AWS EKS MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  cluster_name = var.cluster_name

  # Operational tags applied across EKS resources
  common_tags = merge(
    var.tags,
    {
      Module      = "aws-eks"
      Kubernetes  = var.cluster_version
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # Scoped OIDC Issuer URL without https:// prefix for IAM condition evaluation
  oidc_issuer_clean = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}
