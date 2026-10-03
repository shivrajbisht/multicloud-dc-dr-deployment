# ==============================================================================
# ENVIRONMENT: DEV - OUTPUTS DEFINITION
# ==============================================================================

# --- NETWORKING OUTPUTS ---
output "vpc_id" {
  description = "AWS Primary VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_private_subnet_ids" {
  description = "AWS Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "azure_vnet_id" {
  description = "Azure DR VNet ID"
  value       = module.azure_vnet.vnet_id
}

output "azure_aks_subnet_id" {
  description = "Azure AKS Subnet ID"
  value       = module.azure_vnet.aks_subnet_id
}

# --- LOAD BALANCER OUTPUTS ---
output "aws_alb_dns_name" {
  description = "AWS Application Load Balancer DNS Name"
  value       = module.alb.alb_dns_name
}

output "aws_alb_target_group_arn" {
  description = "AWS Target Group ARN (for Pod IP TargetGroupBinding / EC2)"
  value       = module.alb.target_group_arn
}

output "azure_appgw_public_ip" {
  description = "Azure Application Gateway v2 Public IP Address"
  value       = module.azure_app_gateway.public_ip_address
}

# --- BASTION COMPUTE OUTPUTS ---
output "ec2_bastion_public_ip" {
  description = "AWS EC2 Bastion Host Public IP"
  value       = module.ec2_bastion.public_ip
}

output "azure_vm_bastion_public_ip" {
  description = "Azure VM Bastion Host Public IP"
  value       = module.azure_vm_bastion.public_ip
}

# --- EKS CLUSTER OUTPUTS ---
output "eks_cluster_name" {
  description = "AWS EKS Cluster Name"
  value       = module.eks_dc_cluster.cluster_id
}

output "eks_oidc_issuer" {
  description = "AWS EKS OIDC Provider URL"
  value       = module.eks_dc_cluster.oidc_provider_url
}

# --- AKS CLUSTER OUTPUTS ---
output "aks_cluster_name" {
  description = "Azure AKS Cluster Name"
  value       = module.aks_dr_cluster.cluster_name
}

output "aks_oidc_issuer" {
  description = "Azure AKS OIDC Issuer URL"
  value       = module.aks_dr_cluster.oidc_issuer_url
}
