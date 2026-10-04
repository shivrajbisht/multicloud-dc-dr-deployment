# ==============================================================================
# AZURE ENTRA ID (AZURE AD) & RBAC IDENTITY TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Microsoft Entra ID Security Groups: DevOps-Admins, Developers, Auditors
#   - App Registration & Service Principal for Automated CI/CD Execution
#   - Azure RBAC Role Assignments (Contributor, Reader) at Resource Group level
#   - Full Lifecycle Preconditions & Postconditions
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. MICROSOFT ENTRA ID SECURITY GROUPS (ROLE-BASED ACCESS CONTROL)
# ------------------------------------------------------------------------------

resource "azuread_group" "devops_admins" {
  display_name     = "${var.company_prefix}-${var.environment}-EntraID-DevOps-Admins"
  security_enabled = true
  description      = "Entra ID Security Group for DevOps Administrators with full contributor rights"
}

resource "azuread_group" "developers" {
  display_name     = "${var.company_prefix}-${var.environment}-EntraID-Developers"
  security_enabled = true
  description      = "Entra ID Security Group for Developers with read-only & deployment access"
}

resource "azuread_group" "auditors" {
  display_name     = "${var.company_prefix}-${var.environment}-EntraID-Security-Auditors"
  security_enabled = true
  description      = "Entra ID Security Group for Compliance & Security Auditors"
}

# ------------------------------------------------------------------------------
# 2. AZURE AD APPLICATION REGISTRATION & SERVICE PRINCIPAL FOR AUTOMATION
# ------------------------------------------------------------------------------

resource "azuread_application" "automation_app" {
  display_name = "${var.company_prefix}-${var.environment}-sp-automation"
}

resource "azuread_service_principal" "automation_sp" {
  client_id                    = azuread_application.automation_app.client_id
  app_role_assignment_required = false

  tags = ["Automation", "CI-CD", var.environment]
}

# ------------------------------------------------------------------------------
# 3. AZURE RBAC ROLE ASSIGNMENTS SCOPED TO RESOURCE GROUP
# ------------------------------------------------------------------------------

# Assign 'Contributor' role to DevOps Admins Group
resource "azurerm_role_assignment" "devops_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.devops_admins.object_id
}

# Assign 'Reader' role to Developers Group
resource "azurerm_role_assignment" "developer_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azuread_group.developers.object_id
}

# Assign 'Contributor' role to Service Principal for CI/CD Automation
resource "azurerm_role_assignment" "sp_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.automation_sp.object_id

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = length(var.resource_group_id) > 0
      error_message = "PRECONDITION FAILURE: resource_group_id cannot be empty for Azure RBAC role assignment."
    }
    postcondition {
      condition     = self.role_definition_name == "Contributor"
      error_message = "POSTCONDITION FAILURE: Created role assignment must be Contributor."
    }
  }
}
