# ==============================================================================
# AWS SECURITY GROUPS MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "bastion_sg_id" {
  description = "Security Group ID for Bastion Host"
  value       = aws_security_group.bastion.id
}

output "app_ec2_sg_id" {
  description = "Security Group ID for Application EC2 Instances"
  value       = aws_security_group.app_ec2.id
}

output "eks_workers_sg_id" {
  description = "Security Group ID for EKS Worker Nodes"
  value       = aws_security_group.eks_workers.id
}

output "rds_sg_id" {
  description = "Security Group ID for RDS PostgreSQL"
  value       = aws_security_group.rds.id
}

output "elasticache_sg_id" {
  description = "Security Group ID for ElastiCache Valkey"
  value       = aws_security_group.elasticache.id
}

output "alb_sg_id" {
  description = "Security Group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}
