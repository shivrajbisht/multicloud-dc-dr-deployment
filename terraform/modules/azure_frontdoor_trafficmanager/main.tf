# ==============================================================================
# AZURE FRONT DOOR & TRAFFIC MANAGER DC-DR ROUTING TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Global Load Balancing across AWS EKS Primary DC and Azure AKS Secondary DR
#   - Automated Health Probe Checks on HTTPS Port 443
#   - Azure Front Door Standard/Premium CDN + Web Application Firewall (WAF)
#   - Azure Traffic Manager Priority / Performance Failover Policy
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
# 1. AZURE FRONT DOOR PROFILE & ENDPOINT
# ------------------------------------------------------------------------------

resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"

  tags = merge(
    var.tags,
    {
      Name        = var.profile_name
      Environment = var.environment
      Role        = "Global-FrontDoor-CDN"
    }
  )
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "${var.profile_name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

# ------------------------------------------------------------------------------
# 2. FRONT DOOR ORIGIN GROUP & AUTOMATED HEALTH PROBES FOR DC-DR
# ------------------------------------------------------------------------------

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "dc-dr-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  session_affinity_enabled = false

  # Health Probe Configuration on HTTPS Port 443
  health_probe {
    interval_in_seconds = 15
    path                = "/health"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

# --- Origin 1: AWS EKS Primary DC (Priority 1) ---
resource "azurerm_cdn_frontdoor_origin" "dc_eks_origin" {
  name                          = "primary-dc-eks-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  host_name          = var.dc_eks_ingress_host
  http_port          = 80
  https_port         = 443
  origin_host_header = var.dc_eks_ingress_host
  priority           = 1 # Primary Priority Target
  weight             = 1000
}

# --- Origin 2: Azure AKS Secondary DR (Priority 2 - Failover Target) ---
resource "azurerm_cdn_frontdoor_origin" "dr_aks_origin" {
  name                          = "secondary-dr-aks-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  host_name          = var.dr_aks_ingress_host
  http_port          = 80
  https_port         = 443
  origin_host_header = var.dr_aks_ingress_host
  priority           = 2 # Secondary DR Target
  weight             = 1000
}

# ------------------------------------------------------------------------------
# 3. AZURE TRAFFIC MANAGER PROFILE (PRIORITY / PERFORMANCE FAILOVER)
# ------------------------------------------------------------------------------

resource "azurerm_traffic_manager_profile" "tm_profile" {
  name                   = "${var.profile_name}-tm"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority" # Priority-based active-passive failover

  dns_config {
    relative_name = "${var.profile_name}-tm"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 3
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.profile_name}-tm"
      Environment = var.environment
    }
  )
}

# Traffic Manager Endpoint 1: Primary EKS DC
resource "azurerm_traffic_manager_external_endpoint" "primary_eks_endpoint" {
  name               = "primary-dc-eks"
  profile_id         = azurerm_traffic_manager_profile.tm_profile.id
  target             = var.dc_eks_ingress_host
  endpoint_status    = "Enabled"
  priority           = 1
  endpoint_location  = "East US"
}

# Traffic Manager Endpoint 2: Secondary AKS DR
resource "azurerm_traffic_manager_external_endpoint" "secondary_aks_endpoint" {
  name               = "secondary-dr-aks"
  profile_id         = azurerm_traffic_manager_profile.tm_profile.id
  target             = var.dr_aks_ingress_host
  endpoint_status    = "Enabled"
  priority           = 2
  endpoint_location  = "West US"
}
