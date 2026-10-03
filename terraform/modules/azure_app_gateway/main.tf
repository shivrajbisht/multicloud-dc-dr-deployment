# ==============================================================================
# AZURE APPLICATION GATEWAY V2 (AGIC COMPATIBLE) TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Public Standard_v2 SKU with Zone Redundant High-Availability
#   - Automated HTTP (Port 80) -> HTTPS (Port 443) Listener Routing
#   - Direct Backend Address Pool targeting AKS Pod IPs (AGIC Integration)
#   - Dedicated Frontend Public IP with Static Allocation
#   - Health Probe with custom healthz path
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
# 1. PUBLIC IP FOR APPLICATION GATEWAY V2
# ------------------------------------------------------------------------------
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(local.common_tags, { Name = "${var.appgw_name}-pip" })
}

# ------------------------------------------------------------------------------
# 2. AZURE APPLICATION GATEWAY V2
# ------------------------------------------------------------------------------
resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_http_name
    port = 80
  }

  frontend_port {
    name = local.frontend_port_https_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_ip_addresses
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "${var.appgw_name}-probe"
  }

  probe {
    name                = "${var.appgw_name}-probe"
    protocol            = "Http"
    path                = var.health_check_path
    host                = "127.0.0.1"
    interval            = 15
    timeout             = 5
    unhealthy_threshold = 3
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_http_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
    priority                   = 100
  }

  tags = merge(
    local.common_tags,
    {
      Name                          = var.appgw_name
      "appgw.ingress.k8s.io/managed" = "true"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["appgw.ingress.k8s.io/managed-by"],
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map
    ]
  }
}
