# ==============================================================================
# AWS EC2 INSTANCE TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Latest Amazon Linux 2023 AMI fetched via DATA BLOCK (no hardcoded AMI IDs)
#   - DYNAMIC BLOCK for additional EBS volume attachments
#   - Root EBS volume encrypted with KMS CMK
#   - All additional EBS volumes encrypted
#   - IMDSv2 enforced (Instance Metadata Service v2 for security)
#   - Optional IAM Instance Profile for SSM Session Manager access
#   - Suitable for: Bastion Host, App Server, CI/CD Runner
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
# 1. DATA BLOCK: FETCH LATEST AMAZON LINUX 2023 AMI DYNAMICALLY
#    This avoids hardcoding AMI IDs which differ across regions
# ------------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # Only trust official Amazon AMIs

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] # Amazon Linux 2023 x86_64
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ------------------------------------------------------------------------------
# 2. KMS KEY FOR EBS VOLUME ENCRYPTION
# ------------------------------------------------------------------------------

resource "aws_kms_key" "ebs_kms" {
  description             = "KMS CMK for EC2 EBS Volume Encryption - ${local.instance_full_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.common_tags, { Name = "${local.instance_full_name}-ebs-kms" })
}

# ------------------------------------------------------------------------------
# 3. EC2 INSTANCE PROVISIONING
# ------------------------------------------------------------------------------

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.amazon_linux_2023.id  # Dynamically fetched AMI
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_pair_name
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = var.iam_instance_profile_name

  # Bootstrap script for system initialization
  user_data = var.user_data != "" ? var.user_data : null

  # --- ENFORCE IMDSV2 (INSTANCE METADATA SERVICE v2) ---
  # Prevents SSRF-based credential theft attacks
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Forces IMDSv2
    http_put_response_hop_limit = 1
  }

  # --- ENCRYPTED ROOT EBS VOLUME (KMS CMK) ---
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size_gb
    encrypted             = true
    kms_key_id            = aws_kms_key.ebs_kms.arn
    delete_on_termination = true

    tags = merge(local.common_tags, { Name = "${local.instance_full_name}-root-ebs" })
  }

  # --- DYNAMIC BLOCK: ADDITIONAL EBS VOLUMES ---
  # Attach any number of additional encrypted EBS volumes from variable list
  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      encrypted             = ebs_block_device.value.encrypted
      kms_key_id            = aws_kms_key.ebs_kms.arn
      delete_on_termination = true
    }
  }

  tags = local.common_tags

  lifecycle {
    # Prevent accidental termination of production instances
    ignore_changes = [ami] # Don't destroy instance on AMI refresh
  }
}
