# ==============================================================================
# AWS ELASTICACHE VALKEY REUSABLE TERRAFORM MODULE
# ==============================================================================
# Engine: Valkey (Open-Source Redis Compatible Engine)
# Security Features:
#   - 100% Encryption at Rest: AWS KMS Customer Managed Key (CMK)
#   - 100% Encryption in Transit: TLS Encryption Enabled (transit_encryption_enabled = true)
#   - Multi-AZ HA with Automatic Failover enabled across private subnets
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
# 1. AWS KMS CUSTOMER MANAGED KEY (CMK) FOR VALKEY CACHE ENCRYPTION AT REST
# ------------------------------------------------------------------------------

resource "aws_kms_key" "valkey_kms_key" {
  description             = "AWS KMS Customer Managed Key (CMK) for ElastiCache Valkey Encryption at Rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.replication_group_id}-valkey-kms"
      Environment = var.environment
      Security    = "CMK-Encryption-At-Rest"
    }
  )
}

resource "aws_kms_alias" "valkey_kms_alias" {
  name          = "alias/${var.replication_group_id}-valkey-cmk"
  target_key_id = aws_kms_key.valkey_kms_key.key_id
}

# ------------------------------------------------------------------------------
# 2. ELASTICACHE SUBNET GROUP ACROSS PRIVATE SUBNETS
# ------------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "valkey_subnet_group" {
  name        = "${var.replication_group_id}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for Multi-AZ ElastiCache Valkey deployment"

  tags = merge(
    var.tags,
    {
      Name        = "${var.replication_group_id}-subnet-group"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 3. SECURITY GROUP FOR VALKEY CACHE CLUSTER
# ------------------------------------------------------------------------------

resource "aws_security_group" "valkey_sg" {
  name        = "${var.replication_group_id}-valkey-sg"
  description = "Security group allowing ingress on Valkey port 6379 from app workloads"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow TLS encrypted traffic on port 6379 from application nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "Allow outbound communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.replication_group_id}-valkey-sg"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 4. ELASTICACHE VALKEY REPLICATION GROUP WITH CMK & TLS ENCRYPTION
# ------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id        = var.replication_group_id
  description                 = "Production Multi-AZ ElastiCache Valkey Cluster with CMK and TLS encryption"
  engine                      = "valkey"
  engine_version              = "7.2"
  node_type                   = var.node_type
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.valkey_subnet_group.name
  security_group_ids          = [aws_security_group.valkey_sg.id]

  # --- ENCRYPTION AT REST CONFIGURATION USING KMS CMK ---
  at_rest_encryption_enabled  = true
  kms_key_id                  = aws_kms_key.valkey_kms_key.arn

  # --- ENCRYPTION IN TRANSIT CONFIGURATION (TLS & AUTH TOKEN) ---
  transit_encryption_enabled  = true
  auth_token                  = var.auth_token

  # --- HIGH AVAILABILITY & MULTI-AZ FAILOVER ---
  automatic_failover_enabled  = true
  multi_az_enabled            = true
  num_node_groups             = var.num_node_groups
  replicas_per_node_group     = var.replicas_per_node_group

  snapshot_retention_limit    = 7
  snapshot_window             = "02:00-03:00"

  tags = merge(
    var.tags,
    {
      Name        = var.replication_group_id
      Engine      = "Valkey-7.2"
      Environment = var.environment
      Security    = "Fully-Encrypted-CMK-TLS"
    }
  )
}
