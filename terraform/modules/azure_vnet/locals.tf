# ==============================================================================
# AZURE VNET MODULE - LOCALS DEFINITION
# ==============================================================================
# Uses cidrsubnet() to carve out 3 public and 3 private subnets dynamically
# from the VNet base address space — mirroring the AWS VPC module pattern.
# ==============================================================================

locals {
  base_cidr = var.vnet_address_space[0]

  # Carve 3 PUBLIC subnets — /20 blocks starting at offset 0
  # Example: 10.1.0.0/16 -> 10.1.0.0/20, 10.1.16.0/20, 10.1.32.0/20
  public_subnet_prefixes = [
    for i in range(3) : cidrsubnet(local.base_cidr, 4, i)
  ]

  # Carve 3 PRIVATE subnets — /20 blocks starting at offset 10 (avoid overlap)
  # Example: 10.1.0.0/16 -> 10.1.160.0/20, 10.1.176.0/20, 10.1.192.0/20
  private_subnet_prefixes = [
    for i in range(3) : cidrsubnet(local.base_cidr, 4, i + 10)
  ]

  # AKS dedicated subnet — /22 block for pod & node CIDR space
  aks_subnet_prefix = cidrsubnet(local.base_cidr, 8, 250)

  common_tags = merge(
    var.tags,
    {
      Module      = "azure-vnet"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
