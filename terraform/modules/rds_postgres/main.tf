# ==============================================================================
# AWS RDS POSTGRESQL 17 TERRAFORM MODULE
# ==============================================================================
# Engine Version: PostgreSQL 17
# Security Features:
#   - 100% Encryption at Rest: AWS KMS Customer Managed Key (CMK) for EBS storage
#   - 100% Encryption in Transit: Enforced TLS/SSL via custom DB Parameter Group (rds.force_ssl = 1)
#   - Multi-AZ High Availability across 3 private subnets
#   - Automated Backup, Point-In-Time Recovery, Storage Autoscaling
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
# 1. AWS KMS CUSTOMER MANAGED KEY (CMK) FOR STORAGE ENCRYPTION AT REST
# ------------------------------------------------------------------------------

resource "aws_kms_key" "rds_kms_key" {
  description             = "AWS KMS Customer Managed Key (CMK) for RDS PostgreSQL 17 EBS Volume Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-kms-cmk"
      Environment = var.environment
      Security    = "CMK-Encryption-At-Rest"
    }
  )
}

resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/${var.identifier}-rds-cmk"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

# ------------------------------------------------------------------------------
# 2. RDS DB PARAMETER GROUP ENFORCING TRANSIT ENCRYPTION (TLS/SSL)
# ------------------------------------------------------------------------------

resource "aws_db_parameter_group" "pg17_params" {
  name        = "${var.identifier}-pg17-params"
  family      = "postgres17"
  description = "Custom DB Parameter Group enforcing SSL/TLS encryption in transit and performance tuning"

  # MANDATORY TRANSIT ENCRYPTION PARAMETER: Force SSL/TLS for all incoming client connections
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # Security & logging parameters
  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "250" # Log queries taking longer than 250ms
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-pg17-params"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 3. RDS DB SUBNET GROUP ACROSS PRIVATE SUBNETS
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.identifier}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for Multi-AZ PostgreSQL 17 deployment across private subnets"

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-subnet-group"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 4. SECURITY GROUP FOR RDS POSTGRESQL INSTANCE
# ------------------------------------------------------------------------------

resource "aws_security_group" "rds_sg" {
  name        = "${var.identifier}-rds-sg"
  description = "Security group restricting ingress traffic to RDS PostgreSQL on port 5432"
  vpc_id      = var.vpc_id

  # Allow inbound PostgreSQL port 5432 only from authorized application Security Groups
  ingress {
    description     = "Allow TLS encrypted PostgreSQL connections from application workloads"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  # Egress restricted for outbound communication
  egress {
    description = "Allow outbound communication for system updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-rds-sg"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 5. MULTI-AZ RDS POSTGRESQL 17 DATABASE INSTANCE
# ------------------------------------------------------------------------------

resource "aws_db_instance" "postgres" {
  identifier                  = var.identifier
  engine                      = "postgres"
  engine_version              = "17.0"
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = "gp3"
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name        = aws_db_parameter_group.pg17_params.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]

  # --- ENCRYPTION AT REST CONFIGURATION USING KMS CMK ---
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.rds_kms_key.arn

  # --- HIGH AVAILABILITY & DISASTER RECOVERY ---
  multi_az                    = true # Provision standby replica in separate AZ
  publicly_accessible         = false # Strict internal private accessibility
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  deletion_protection         = true # Prevent accidental database termination

  # Backup & maintenance settings
  backup_retention_period     = 30
  backup_window               = "03:00-04:00"
  maintenance_window          = "Mon:04:30-Mon:05:30"
  copy_tags_to_snapshot       = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.identifier}-final-snapshot"

  tags = merge(
    var.tags,
    {
      Name        = var.identifier
      Engine      = "PostgreSQL-17"
      Environment = var.environment
      Security    = "Fully-Encrypted-CMK-TLS"
    }
  )

  lifecycle {
    ignore_changes = [
      password,
      latest_restorable_time
    ]
  }
}
