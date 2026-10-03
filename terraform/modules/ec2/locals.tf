# ==============================================================================
# AWS EC2 MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  # Standardized instance name
  instance_full_name = "${var.instance_name}-${var.environment}"

  # Merge common tags with module-specific metadata
  common_tags = merge(
    var.tags,
    {
      Name        = local.instance_full_name
      Module      = "aws-ec2"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
