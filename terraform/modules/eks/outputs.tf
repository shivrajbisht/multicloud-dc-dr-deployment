# ==============================================================================
# AWS EKS MODULE - OUTPUTS DEFINITION
# ==============================================================================
# Exports key outputs for consumption by parent modules and CI/CD pipelines.
# ==============================================================================

output "cluster_id" {
  description = "The name/id of the Amazon EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint URL for the Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC Provider created for IRSA"
  value       = aws_iam_oidc_provider.eks_oidc.arn
}

output "oidc_provider_url" {
  description = "URL of the IAM OIDC Provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "on_demand_nodegroup_arn" {
  description = "ARN of the On-Demand EKS Managed Node Group"
  value       = aws_eks_node_group.on_demand.arn
}

output "spot_nodegroup_1_arn" {
  description = "ARN of the Spot Pool 1 EKS Managed Node Group"
  value       = aws_eks_node_group.spot_pool_1.arn
}

output "spot_nodegroup_2_arn" {
  description = "ARN of the Spot Pool 2 EKS Managed Node Group"
  value       = aws_eks_node_group.spot_pool_2.arn
}
