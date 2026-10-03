# ==============================================================================
# AZURE APPLICATION GATEWAY V2 MODULE - LOCALS DEFINITION
# ==============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "Azure-AppGateway"
    }
  )

  # Application Gateway configuration block naming
  gateway_ip_configuration_name = "${var.appgw_name}-gw-ip-config"
  frontend_port_http_name       = "${var.appgw_name}-frontend-port-http"
  frontend_port_https_name      = "${var.appgw_name}-frontend-port-https"
  frontend_ip_configuration_name= "${var.appgw_name}-frontend-ip-config"
  backend_address_pool_name     = "${var.appgw_name}-backend-pool"
  backend_http_settings_name    = "${var.appgw_name}-http-settings"
  http_listener_name            = "${var.appgw_name}-http-listener"
  https_listener_name           = "${var.appgw_name}-https-listener"
  request_routing_rule_name     = "${var.appgw_name}-routing-rule"
}
