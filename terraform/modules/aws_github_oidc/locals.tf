# ==============================================================================
# AWS GITHUB OIDC MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  
  # GitHub OIDC thumbprint for TLS verification
  github_oidc_thumbprints = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a218b57558a77943441bb928097bca964306"
  ]

  # Subject claim condition restricting access to specified repository and branches/pull requests
  github_sub_claim = "repo:${var.github_org}/${var.github_repo}:*"

  module_tags = merge(
    var.tags,
    {
      Module      = "aws-github-oidc"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Security    = "Passwordless-OIDC"
    }
  )
}
