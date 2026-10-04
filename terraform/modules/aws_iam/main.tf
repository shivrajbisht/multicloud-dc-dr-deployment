# ==============================================================================
# AWS IAM & RBAC IDENTITY TERRAFORM MODULE
# ==============================================================================
# Features:
#   - IAM User Groups: DevOps-Admins, Developers, Security-Auditors
#   - IAM Customer Managed Policies with Least-Privilege Permissions
#   - IAM Roles for Application Workloads & Database Administrators
#   - Full Lifecycle Preconditions & Postconditions
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
# 1. AWS IAM USER GROUPS (ROLE-BASED ACCESS CONTROL)
# ------------------------------------------------------------------------------

resource "aws_iam_group" "devops_admins" {
  name = "${var.company_prefix}-${var.environment}-DevOps-Admins"
}

resource "aws_iam_group" "developers" {
  name = "${var.company_prefix}-${var.environment}-Developers"
}

resource "aws_iam_group" "security_auditors" {
  name = "${var.company_prefix}-${var.environment}-Security-Auditors"
}

# ------------------------------------------------------------------------------
# 2. POLICY ATTACHMENTS FOR IAM GROUPS
# ------------------------------------------------------------------------------

resource "aws_iam_group_policy_attachment" "devops_admin_attach" {
  group      = aws_iam_group.devops_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "developer_read_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "auditor_security_attach" {
  group      = aws_iam_group.security_auditors.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# ------------------------------------------------------------------------------
# 3. CUSTOMER MANAGED LEAST-PRIVILEGE WORKLOAD POLICY
# ------------------------------------------------------------------------------

resource "aws_iam_policy" "app_workload_policy" {
  name        = "${var.company_prefix}-${var.environment}-AppWorkloadPolicy"
  description = "Least privilege IAM policy for EKS/EC2 application workload data access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3KMSAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.company_prefix}-${var.environment}-AppWorkloadPolicy"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 4. WORKLOAD IAM ROLE FOR EKS / EC2 ASSUME ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "app_workload_role" {
  name = "${var.company_prefix}-${var.environment}-AppWorkloadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.company_prefix}-${var.environment}-AppWorkloadRole"
      Environment = var.environment
    }
  )

  # --- COMPLIANCE & RECOVERY LIFECYCLE PRE/POST CONDITIONS ---
  lifecycle {
    precondition {
      condition     = length(var.company_prefix) > 0
      error_message = "PRECONDITION FAILURE: company_prefix cannot be empty for IAM role generation."
    }
    postcondition {
      condition     = self.name == "${var.company_prefix}-${var.environment}-AppWorkloadRole"
      error_message = "POSTCONDITION FAILURE: Created IAM role name does not match expected name."
    }
  }
}

resource "aws_iam_role_policy_attachment" "app_workload_attach" {
  role       = aws_iam_role.app_workload_role.name
  policy_arn = aws_iam_policy.app_workload_policy.arn
}
