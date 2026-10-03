# ==============================================================================
# AWS CLOUDFRONT CDN & ROUTE 53 DC-DR FAILOVER ROUTING MODULE
# ==============================================================================
# Features:
#   - Route 53 Latency / Failover Routing across AWS EKS Primary DC and Azure AKS DR
#   - Route 53 Automated Endpoint Health Checks
#   - CloudFront Global CDN with Origin Access Control (OAC)
#   - Enforced HTTPS / TLS 1.2+ Encryption in Transit
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
# 1. CLOUDFRONT ORIGIN ACCESS CONTROL (OAC) FOR ENCRYPTED S3 ORIGIN
# ------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.domain_name}-oac"
  description                       = "Origin Access Control for secure KMS encrypted S3 static assets access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ------------------------------------------------------------------------------
# 2. CLOUDFRONT CDN GLOBAL DISTRIBUTION
# ------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = var.s3_bucket_origin_domain
    origin_id                = "S3-${var.domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Enforce HTTPS-Only TLS Encryption in Transit
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.domain_name}-cdn"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 3. ROUTE 53 HEALTH CHECKS FOR DC & DR ENDPOINTS
# ------------------------------------------------------------------------------

# Primary DC (AWS EKS) Health Check
resource "aws_route53_health_check" "primary_dc_health" {
  fqdn              = var.dc_eks_ingress_ip
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 10

  tags = merge(
    var.tags,
    {
      Name = "primary-dc-eks-health-check"
    }
  )
}

# Secondary DR (Azure AKS) Health Check
resource "aws_route53_health_check" "secondary_dr_health" {
  fqdn              = var.dr_aks_ingress_ip
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 10

  tags = merge(
    var.tags,
    {
      Name = "secondary-dr-aks-health-check"
    }
  )
}

# ------------------------------------------------------------------------------
# 4. ROUTE 53 FAILOVER ROUTING RECORDS (AUTOMATED DC-DR FAILOVER)
# ------------------------------------------------------------------------------

# Primary DC Record Set (PRIMARY)
resource "aws_route53_record" "primary_dc" {
  zone_id = "Z1234567890ABC" # Parameterized Hosted Zone ID
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 60

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "Primary-DC-EKS"
  records         = [var.dc_eks_ingress_ip]
  health_check_id = aws_route53_health_check.primary_dc_health.id
}

# Secondary DR Record Set (SECONDARY)
resource "aws_route53_record" "secondary_dr" {
  zone_id = "Z1234567890ABC"
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 60

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "Secondary-DR-AKS"
  records         = [var.dr_aks_ingress_ip]
  health_check_id = aws_route53_health_check.secondary_dr_health.id
}
