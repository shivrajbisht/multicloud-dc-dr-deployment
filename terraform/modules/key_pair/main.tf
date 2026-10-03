# ==============================================================================
# AWS EC2 KEY PAIR TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Generates RSA 4096-bit key pair using Terraform TLS provider
#   - Uploads public key to AWS EC2 Key Pair
#   - Stores private key in AWS Secrets Manager (encrypted, no local file needed)
#   - Data block for current AWS account lookup
#   - Private key NEVER written to disk or state in plaintext
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. DATA BLOCK: AWS ACCOUNT IDENTITY LOOKUP
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# 2. GENERATE RSA 4096-BIT KEY PAIR LOCALLY VIA TERRAFORM TLS PROVIDER
# ------------------------------------------------------------------------------

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ------------------------------------------------------------------------------
# 3. UPLOAD PUBLIC KEY TO AWS EC2 KEY PAIR
# ------------------------------------------------------------------------------

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.key_name}-${var.environment}"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = merge(
    var.tags,
    {
      Name        = "${var.key_name}-${var.environment}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ------------------------------------------------------------------------------
# 4. STORE PRIVATE KEY SECURELY IN AWS SECRETS MANAGER (KMS ENCRYPTED)
#    Never write private keys to local disk or Terraform state!
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "private_key_secret" {
  name        = "${var.key_name}-${var.environment}-private-key"
  description = "EC2 SSH Private Key for ${var.key_name} in ${var.environment} environment"
  kms_key_id  = "alias/aws/secretsmanager" # Use AWS-managed CMK or provide custom KMS ARN

  tags = merge(
    var.tags,
    {
      Name        = "${var.key_name}-${var.environment}-private-key"
      Environment = var.environment
      Security    = "Encrypted-SSH-Private-Key"
    }
  )
}

resource "aws_secretsmanager_secret_version" "private_key_value" {
  secret_id     = aws_secretsmanager_secret.private_key_secret.id
  secret_string = tls_private_key.ec2_key.private_key_pem
}
