# ==============================================================================
# AZURE VIRTUAL NETWORK (VNET) TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Virtual Network with DNS Servers
#   - 3 PUBLIC Subnets across 3 AZs (Bastion, Load Balancer, DMZ)
#   - 3 PRIVATE Subnets across 3 AZs (AKS Nodes, Databases, Cache)
#   - 1 AKS Dedicated Subnet for delegated AKS pod networking
#   - NAT Gateway with Public IP for Private Subnet internet egress
#   - Public & Private Route Tables
#   - cidrsubnet() function used in locals.tf for all CIDR calculations
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. AZURE VIRTUAL NETWORK
# ------------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = merge(local.common_tags, { Name = "${var.vnet_name}-${var.environment}" })

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = length(var.vnet_address_space) > 0
      error_message = "SECURITY PRECONDITION FAILURE: vnet_address_space must contain at least one valid CIDR block."
    }
    postcondition {
      condition     = length(self.address_space) > 0
      error_message = "POSTCONDITION FAILURE: Created Virtual Network must have a non-empty address space."
    }
  }
}

# ------------------------------------------------------------------------------
# 2. PUBLIC SUBNETS (3 AZs) - CIDRs computed via cidrsubnet() in locals.tf
# ------------------------------------------------------------------------------

resource "azurerm_subnet" "public" {
  count                = 3
  name                 = "${var.vnet_name}-${var.environment}-public-subnet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.public_subnet_prefixes[count.index]]
}

# ------------------------------------------------------------------------------
# 3. PRIVATE SUBNETS (3 AZs) - CIDRs computed via cidrsubnet() in locals.tf
# ------------------------------------------------------------------------------

resource "azurerm_subnet" "private" {
  count                = 3
  name                 = "${var.vnet_name}-${var.environment}-private-subnet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.private_subnet_prefixes[count.index]]
}

# ------------------------------------------------------------------------------
# 4. AKS DEDICATED SUBNET (DELEGATED FOR AKS VIRTUAL NODE / CNI)
# ------------------------------------------------------------------------------

resource "azurerm_subnet" "aks" {
  name                 = "${var.vnet_name}-${var.environment}-aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.aks_subnet_prefix]

  # No service endpoint delegation for kubenet; add for Azure CNI if needed
}

# ------------------------------------------------------------------------------
# 5. PUBLIC IP FOR NAT GATEWAY
# ------------------------------------------------------------------------------

resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.vnet_name}-${var.environment}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(local.common_tags, { Name = "${var.vnet_name}-${var.environment}-nat-pip" })
}

# ------------------------------------------------------------------------------
# 6. AZURE NAT GATEWAY (PRIVATE SUBNET OUTBOUND INTERNET EGRESS)
# ------------------------------------------------------------------------------

resource "azurerm_nat_gateway" "nat" {
  name                = "${var.vnet_name}-${var.environment}-nat-gw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"

  tags = merge(local.common_tags, { Name = "${var.vnet_name}-${var.environment}-nat-gw" })
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

# Associate NAT Gateway with each private subnet
resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  count          = 3
  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
