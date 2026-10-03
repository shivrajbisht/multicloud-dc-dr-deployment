# ==============================================================================
# AWS ACM CERTIFICATE MODULE - LOCALS DEFINITION
# ==============================================================================
# Local values for calculated certificate metadata, tags, and domain mappings.
# ==============================================================================

locals {
  # Merge custom tags with module standard operational tags
  module_tags = merge(
    var.tags,
    {
      Module      = "acm-certificate"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Security    = "TLS-1.2-1.3-Encrypted"
    }
  )

  # Sanitized identifier name for DNS record labeling
  sanitized_domain = replace(var.domain_name, "*", "wildcard")
}
