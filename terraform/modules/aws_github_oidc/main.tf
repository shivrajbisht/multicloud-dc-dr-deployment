# ==============================================================================
# AWS GITHUB ACTIONS OIDC IDENTITY TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Passwordless Authentication for GitHub Actions CI/CD via OpenID Connect (OIDC)
#   - IAM Trust Policy scoping permissions strictly to repo:${github_org}/${github_repo}:*
#   - Data block for AWS Account ID lookup
#   - Local values for Thumbprint management
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. DATA BLOCK: AWS ACCOUNT CALLER IDENTITY LOOKUP
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# 2. AWS IAM OPENID CONNECT (OIDC) PROVIDER FOR GITHUB ACTIONS
# ------------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = local.github_oidc_thumbprints

  tags = merge(
    local.module_tags,
    {
      Name = "github-actions-oidc-provider"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. IAM ROLE FOR GITHUB ACTIONS WITH STRICT SUBJECT CLAIM SCOPING
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_sub_claim]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json

  tags = merge(
    local.module_tags,
    {
      Name = var.role_name
    }
  )

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = length(var.github_org) > 0 && length(var.github_repo) > 0
      error_message = "SECURITY PRECONDITION FAILURE: github_org and github_repo must not be empty for OIDC trust scoping."
    }
    postcondition {
      condition     = self.name == var.role_name
      error_message = "POSTCONDITION FAILURE: Created IAM role name does not match requested role_name."
    }
  }
}

# Attach Administrator / Deployment Permissions to Role
resource "aws_iam_role_policy_attachment" "administrator_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
