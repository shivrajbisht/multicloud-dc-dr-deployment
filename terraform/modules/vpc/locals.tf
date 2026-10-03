# ==============================================================================
# AWS VPC MODULE - LOCALS DEFINITION
# ==============================================================================
# Uses cidrsubnet() function to dynamically carve 3 Public and 3 Private Subnets
# from the base VPC CIDR block across 3 Availability Zones.
# ==============================================================================

locals {
  # All Availability Zones derived automatically via data block in main.tf
  # We use the first 3 AZs for HA deployment
  az_count = 3

  # Dynamically generate 3 public subnet CIDRs using cidrsubnet()
  # cidrsubnet(base_cidr, newbits, netnum) - carves /20 subnets from /16
  # Example: 10.0.0.0/16 -> 10.0.0.0/20, 10.0.16.0/20, 10.0.32.0/20
  public_subnet_cidrs = [
    for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 4, i)
  ]

  # Dynamically generate 3 private subnet CIDRs using cidrsubnet()
  # Private subnets start from netnum offset 10 to avoid overlap with public
  # Example: 10.0.0.0/16 -> 10.0.160.0/20, 10.0.176.0/20, 10.0.192.0/20
  private_subnet_cidrs = [
    for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 10)
  ]

  # Standardized resource tags for all VPC resources
  common_tags = merge(
    var.tags,
    {
      Module      = "aws-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
