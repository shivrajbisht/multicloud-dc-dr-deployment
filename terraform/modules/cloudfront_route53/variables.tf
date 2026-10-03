# ==============================================================================
# AWS ROUTE 53 & CLOUDFRONT MODULE - VARIABLES DEFINITION
# ==============================================================================

variable "domain_name" {
  type        = string
  description = "Primary domain name (e.g., app.example.com)"
}

variable "s3_bucket_origin_domain" {
  type        = string
  description = "Regional domain name of the origin S3 bucket"
}

variable "dc_eks_ingress_ip" {
  type        = string
  description = "Primary DC EKS Ingress Load Balancer IP / DNS"
}

variable "dr_aks_ingress_ip" {
  type        = string
  description = "Secondary DR AKS Ingress Load Balancer IP / DNS"
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
