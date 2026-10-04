# ==============================================================================
# AWS ACM CERTIFICATE TERRAFORM MODULE WITH AUTOMATED ROUTE 53 DNS VALIDATION
# ==============================================================================
# Features:
#   - Public SSL/TLS Certificate Request via AWS Certificate Manager (ACM)
#   - Automated Route 53 CNAME Validation Record Creation using for_each
#   - Data Blocks for Hosted Zone metadata lookup
#   - Local values for Tag Standardization
#   - Automated Certificate Validation Waiter
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
# 1. DATA BLOCK: ROUTE 53 HOSTED ZONE LOOKUP
# ------------------------------------------------------------------------------

data "aws_route53_zone" "selected" {
  zone_id      = var.route53_zone_id
  private_zone = false
}

# ------------------------------------------------------------------------------
# 2. AWS ACM CERTIFICATE REQUEST (DNS VALIDATION METHOD)
# ------------------------------------------------------------------------------

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = length(var.domain_name) > 0
      error_message = "PRECONDITION FAILURE: Certificate domain_name cannot be empty."
    }
    postcondition {
      condition     = self.validation_method == "DNS"
      error_message = "POSTCONDITION FAILURE: Certificate validation_method must be DNS for automated record management."
    }
  }

  tags = merge(
    local.module_tags,
    {
      Name = "${local.sanitized_domain}-acm-cert"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. AUTOMATED ROUTE 53 DNS VALIDATION CNAME RECORDS (USING FOR_EACH)
# ------------------------------------------------------------------------------

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# ------------------------------------------------------------------------------
# 4. ACM CERTIFICATE VALIDATION WAITER RESOURCE
# ------------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
