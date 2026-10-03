# ==============================================================================
# AWS APPLICATION LOAD BALANCER (ALB) REUSABLE TERRAFORM MODULE
# ==============================================================================
# Features:
#   - Public Internet-Facing Application Load Balancer across 3 Public Subnets
#   - Automated HTTP (Port 80) -> HTTPS (Port 443) 301 Redirect Rule
#   - HTTPS Listener with ACM SSL Certificate Attachment & TLS 1.3/1.2 Security Policy
#   - Target Group supporting "ip" target type for EKS Pod IP routing via AWS Load Balancer Controller
#   - Target Group health checks with configurable path, thresholds, and interval
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
# 1. SECURITY GROUP FOR ALB
# ------------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.alb_name}-sg"
  description = "Security group for ALB allowing inbound HTTP/HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP ingress from internet (redirects to 443)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS ingress from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to targets (EKS Pod IPs / EC2)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.alb_name}-sg" })
}

# ------------------------------------------------------------------------------
# 2. APPLICATION LOAD BALANCER
# ------------------------------------------------------------------------------
resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = concat([aws_security_group.alb_sg.id], var.security_group_ids)
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name                                            = var.alb_name
      "ingress.k8s.aws/stack"                         = var.alb_name
      "elbv2.k8s.aws/pod-readiness-gate-inject"       = "enabled"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. TARGET GROUP (TARGET TYPE: IP FOR POD IP ROUTING / INSTANCE FOR EC2)
# ------------------------------------------------------------------------------
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.alb_name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type # "ip" allows direct pod IP routing for EKS AWS Load Balancer Controller

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(
    local.common_tags,
    {
      Name                                   = "${var.alb_name}-tg"
      "targetgroupbinding.k8s.aws/managed"   = "true"
    }
  )
}

# ------------------------------------------------------------------------------
# 4. HTTP LISTENER (PORT 80) -> 301 REDIRECT TO HTTPS (PORT 443)
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(local.common_tags, { Name = "${var.alb_name}-http-redirect" })
}

# ------------------------------------------------------------------------------
# 5. HTTPS LISTENER (PORT 443) WITH ACM SSL CERTIFICATE
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = merge(local.common_tags, { Name = "${var.alb_name}-https" })
}
