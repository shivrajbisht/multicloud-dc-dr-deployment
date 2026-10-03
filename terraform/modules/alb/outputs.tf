# ==============================================================================
# AWS ALB MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS Name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Canonical Hosted Zone ID of the ALB (for Route53 Alias records)"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the Target Group (for AWS Load Balancer Controller TargetGroupBinding / EC2 registration)"
  value       = aws_lb_target_group.app_tg.arn
}

output "target_group_name" {
  description = "Name of the Target Group"
  value       = aws_lb_target_group.app_tg.name
}

output "alb_security_group_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb_sg.id
}
