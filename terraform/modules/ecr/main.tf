# ==============================================================================
# AWS ECR REPOSITORY TERRAFORM MODULE (KMS CMK ENCRYPTION)
# ==============================================================================
# Features:
#   - Encryption at Rest using AWS KMS Customer Managed Key (CMK)
#   - Image Vulnerability Scanning on Push enabled
#   - Tag Mutability configuration
#   - Automatic Lifecycle Policy to clean old images
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
# 1. AWS KMS CMK FOR ECR CONTAINER IMAGE ENCRYPTION
# ------------------------------------------------------------------------------

resource "aws_kms_key" "ecr_kms_key" {
  description             = "AWS KMS Customer Managed Key for ECR Repository ${var.repository_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.repository_name}-ecr-kms"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AMAZON ECR REPOSITORY PROVISIONING
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # --- ENCRYPTION AT REST VIA KMS CMK ---
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_kms_key.arn
  }

  # --- AUTOMATED VULNERABILITY SCANNING ---
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name        = var.repository_name
      Environment = var.environment
      Security    = "CMK-Encrypted"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. ECR LIFECYCLE POLICY (AUTOMATED UNTAGGED IMAGE PRUNING)
# ------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 20 images and expire old untagged container builds"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
