# ==============================================================================
# AWS S3 BUCKET TERRAFORM MODULE (KMS CMK & ENFORCED TLS IN-TRANSIT)
# ==============================================================================
# Security & HA Features:
#   - Multi-AZ regional storage redundancy
#   - Server-Side Encryption at Rest via AWS KMS Customer Managed Key (CMK)
#   - Mandatory TLS/SSL in Transit via Bucket Policy (Deny HTTP non-SecureTransport)
#   - Block Public Access Enabled
#   - Object Versioning enabled for DR compliance
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
# 1. AWS KMS CMK FOR S3 BUCKET ENCRYPTION AT REST
# ------------------------------------------------------------------------------

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS Customer Managed Key for S3 Bucket ${var.bucket_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.bucket_name}-kms"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AWS S3 BUCKET PROVISIONING
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = merge(
    var.tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
      Security    = "CMK-Encrypted-TLS-Enforced"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. SERVER-SIDE ENCRYPTION AT REST CONFIGURATION (KMS CMK)
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# ------------------------------------------------------------------------------
# 4. S3 VERSIONING CONFIGURATION
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# ------------------------------------------------------------------------------
# 5. BLOCK PUBLIC ACCESS (100% PRIVATE SECURITY GATE)
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# 6. BUCKET POLICY ENFORCING TLS/SSL ENCRYPTION IN TRANSIT
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "enforce_tls_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}
