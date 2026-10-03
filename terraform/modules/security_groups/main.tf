# ==============================================================================
# AWS SECURITY GROUPS TERRAFORM MODULE
# ==============================================================================
# Creates:
#   1. BASTION HOST SG  - SSH from restricted CIDRs only (ingress dynamic block)
#   2. APP EC2 SG       - Dynamic ingress rules from variable, intra-VPC HTTPS
#   3. EKS WORKER SG    - Worker node cluster communication
#   4. RDS SG           - PostgreSQL 5432 from EKS & App SGs only
#   5. ELASTICACHE SG   - Valkey 6379 from EKS & App SGs only
#   6. ALB SG           - HTTP/HTTPS from internet to load balancer
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
# 1. BASTION HOST SECURITY GROUP
#    Dynamic ingress block: Allows SSH from configurable CIDRs (VPN/Office only)
# ------------------------------------------------------------------------------

resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for Bastion Host - restricts SSH access to authorized CIDRs only"
  vpc_id      = var.vpc_id

  # DYNAMIC BLOCK: Build ingress rules for each CIDR provided in var.bastion_ingress_cidrs
  dynamic "ingress" {
    for_each = var.bastion_ingress_cidrs
    content {
      description = "SSH access from ${ingress.value}"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound traffic from Bastion"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-bastion-sg" })
}

# ------------------------------------------------------------------------------
# 2. APPLICATION EC2 SECURITY GROUP
#    Dynamic ingress block: Rule set built from var.app_ec2_ingress_ports list
# ------------------------------------------------------------------------------

resource "aws_security_group" "app_ec2" {
  name        = "${var.environment}-app-ec2-sg"
  description = "Security group for Application EC2 instances - dynamic ingress rules"
  vpc_id      = var.vpc_id

  # DYNAMIC BLOCK: Iterate over app_ec2_ingress_ports list to create flexible rules
  dynamic "ingress" {
    for_each = var.app_ec2_ingress_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow SSH from Bastion Host SG only (principle of least privilege)
  ingress {
    description     = "SSH access from Bastion Host SG only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-app-ec2-sg" })
}

# ------------------------------------------------------------------------------
# 3. EKS WORKER NODE SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "eks_workers" {
  name        = "${var.environment}-eks-workers-sg"
  description = "Security group for EKS Worker Nodes - cluster internal communication"
  vpc_id      = var.vpc_id

  # Allow all intra-node communication within VPC CIDR (required for CNI networking)
  ingress {
    description = "Allow intra-VPC traffic for EKS pod networking (CNI)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow SSH from Bastion Host for debugging
  ingress {
    description     = "SSH from Bastion Host for cluster node debugging"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic for internet egress via NAT GW"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-eks-workers-sg" })
}

# ------------------------------------------------------------------------------
# 4. RDS POSTGRESQL SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-pg-sg"
  description = "Security group for RDS PostgreSQL - allows access from EKS workers and App EC2 only"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL port from EKS Workers
  ingress {
    description     = "PostgreSQL access from EKS Worker Nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_workers.id]
  }

  # Allow PostgreSQL port from App EC2 instances
  ingress {
    description     = "PostgreSQL access from App EC2 Instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_ec2.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-rds-pg-sg" })
}

# ------------------------------------------------------------------------------
# 5. ELASTICACHE VALKEY SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "elasticache" {
  name        = "${var.environment}-elasticache-valkey-sg"
  description = "Security group for ElastiCache Valkey - access from EKS workers and App EC2 only"
  vpc_id      = var.vpc_id

  # Allow Valkey port 6379 from EKS Workers
  ingress {
    description     = "Valkey access from EKS Worker Nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_workers.id]
  }

  # Allow Valkey port 6379 from App EC2 instances
  ingress {
    description     = "Valkey access from App EC2 Instances"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_ec2.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-elasticache-valkey-sg" })
}

# ------------------------------------------------------------------------------
# 6. APPLICATION LOAD BALANCER (ALB) SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB - allows HTTP/HTTPS from internet, forwards to EC2/EKS"
  vpc_id      = var.vpc_id

  # Allow HTTP ingress from internet (will be redirected to HTTPS)
  ingress {
    description = "Allow HTTP from internet (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS ingress from internet
  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound to EC2 and EKS targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-alb-sg" })
}
