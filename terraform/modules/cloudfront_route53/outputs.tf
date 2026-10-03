# ==============================================================================
# AWS ROUTE 53 & CLOUDFRONT MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront CDN distribution"
  value       = aws_cloudfront_distribution.cdn.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "primary_dc_health_check_id" {
  description = "Route 53 Health Check ID for Primary EKS DC"
  value       = aws_route53_health_check.primary_dc_health.id
}
