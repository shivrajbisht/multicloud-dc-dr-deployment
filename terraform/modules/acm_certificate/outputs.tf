# ==============================================================================
# AWS ACM CERTIFICATE MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "certificate_arn" {
  description = "ARN of the validated ACM SSL/TLS certificate"
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "certificate_domain" {
  description = "Primary domain name of the certificate"
  value       = aws_acm_certificate.cert.domain_name
}
