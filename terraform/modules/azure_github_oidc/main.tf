# ==============================================================================
# AZURE GITHUB ACTIONS FEDERATED IDENTITY OIDC TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Passwordless Authentication for GitHub Actions using Azure Federated Credentials
#   - Eliminates stored Azure Service Principal Client Secrets
#   - Data block for Azure Subscription lookup
#   - Local values for Federated Subject formatting
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
# 1. DATA BLOCK: PRIMARY AZURE SUBSCRIPTION LOOKUP
# ------------------------------------------------------------------------------

data "azurerm_subscription" "primary" {}

# ------------------------------------------------------------------------------
# 2. USER ASSIGNED MANAGED IDENTITY PROVISIONING
# ------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "identity" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    local.module_tags,
    {
      Name = var.identity_name
    }
  )
}

# ------------------------------------------------------------------------------
# 3. FEDERATED IDENTITY CREDENTIAL FOR GITHUB ACTIONS (OIDC)
# ------------------------------------------------------------------------------

resource "azurerm_federated_identity_credential" "github_fed" {
  name                = "${var.identity_name}-fed-cred"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.github_issuer
  subject             = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

# ------------------------------------------------------------------------------
# 4. SUBSCRIPTION ROLE ASSIGNMENT FOR GITHUB ACTIONS IDENTITY
# ------------------------------------------------------------------------------

resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}
