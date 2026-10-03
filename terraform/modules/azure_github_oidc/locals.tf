# ==============================================================================
# AZURE GITHUB OIDC MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  github_issuer = "https://token.actions.githubusercontent.com"
  github_subject = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"

  module_tags = merge(
    var.tags,
    {
      Module      = "azure-github-oidc"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Security    = "Federated-Identity-OIDC"
    }
  )
}
