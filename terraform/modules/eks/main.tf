# ==============================================================================
# AWS EKS (ELASTIC KUBERNETES SERVICE) REUSABLE TERRAFORM MODULE
# ==============================================================================
# Target K8s Version: 1.36
# Features:
#   - 3 Private Subnets Deployment across distinct Availability Zones (HA)
#   - 3 EKS Managed Node Groups:
#       1. On-Demand Node Group (Core/System Workloads)
#       2. Spot Node Group 1 (App Workload Pool A)
#       3. Spot Node Group 2 (App Workload Pool B)
#   - AWS IAM OIDC Provider Integration for IRSA (IAM Roles for Service Accounts)
#   - Zero Hardcoded Parameters; 100% Parameterized for Reusability
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. IAM ROLE & POLICY ATTACHMENTS FOR EKS CONTROL PLANE
# ------------------------------------------------------------------------------

# Define IAM Trust Policy for AWS EKS Control Plane Service
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Create IAM Role for EKS Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-control-plane-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-control-plane-role"
      Environment = var.environment
      Component   = "ControlPlane"
    }
  )
}

# Attach AmazonEKSClusterPolicy to Control Plane IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach AmazonEKSVPCResourceController policy for security group & ENI management
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# ------------------------------------------------------------------------------
# 2. AMAZON EKS CONTROL PLANE CLUSTER (KUBERNETES 1.36)
# ------------------------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  # Networking settings mapping to 3 private subnets
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_endpoint
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Enable Control Plane CloudWatch Logging for Audit & Compliance
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller
  ]

  tags = merge(
    var.tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
      Role        = "Kubernetes-ControlPlane"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. AWS IAM OIDC PROVIDER FOR SERVICE ACCOUNTS (IRSA)
# ------------------------------------------------------------------------------
# Enables Kubernetes pods to assume AWS IAM roles fine-grained via Service Accounts

data "tls_certificate" "eks_oidc_issuer" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_oidc_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-oidc-provider"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 4. IAM ROLE & POLICY ATTACHMENTS FOR WORKER NODE GROUPS
# ------------------------------------------------------------------------------

# Define IAM Trust Policy for EC2 Worker Nodes
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create IAM Role for Worker Node Groups
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-worker-node-role"
      Environment = var.environment
      Component   = "WorkerNodes"
    }
  )
}

# Attach AmazonEKSWorkerNodePolicy
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# Attach AmazonEKS_CNI_Policy for VPC CNI networking
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Attach AmazonEC2ContainerRegistryReadOnly for pulling container images from ECR
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# ------------------------------------------------------------------------------
# 5. EKS MANAGED NODE GROUPS (3 SUB-POOLS: 1 ON-DEMAND, 2 SPOT)
# ------------------------------------------------------------------------------

# --- Node Group 1: On-Demand Core Pool (System Components, Operators, Ingress) ---
resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${var.on_demand_node_group.name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = var.on_demand_node_group.instance_types
  disk_size      = var.on_demand_node_group.disk_size

  scaling_config {
    desired_size = var.on_demand_node_group.desired_size
    max_size     = var.on_demand_node_group.max_size
    min_size     = var.on_demand_node_group.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node.kubernetes.io/capacity-type" = "ON_DEMAND"
    "workload-type"                    = "system-critical"
    "environment"                      = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.on_demand_node_group.name}"
      Environment = var.environment
      Capacity    = "ON_DEMAND"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]
}

# --- Node Group 2: Spot App Pool A (Stateless Microservices, Compute Heavy) ---
resource "aws_eks_node_group" "spot_pool_1" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${var.spot_node_group_1.name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = "SPOT"
  instance_types = var.spot_node_group_1.instance_types
  disk_size      = var.spot_node_group_1.disk_size

  scaling_config {
    desired_size = var.spot_node_group_1.desired_size
    max_size     = var.spot_node_group_1.max_size
    min_size     = var.spot_node_group_1.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node.kubernetes.io/capacity-type" = "SPOT"
    "workload-type"                    = "stateless-apps-pool-a"
    "environment"                      = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.spot_node_group_1.name}"
      Environment = var.environment
      Capacity    = "SPOT"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]
}

# --- Node Group 3: Spot App Pool B (Batch Processing & Memory Heavy Workloads) ---
resource "aws_eks_node_group" "spot_pool_2" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${var.spot_node_group_2.name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = "SPOT"
  instance_types = var.spot_node_group_2.instance_types
  disk_size      = var.spot_node_group_2.disk_size

  scaling_config {
    desired_size = var.spot_node_group_2.desired_size
    max_size     = var.spot_node_group_2.max_size
    min_size     = var.spot_node_group_2.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node.kubernetes.io/capacity-type" = "SPOT"
    "workload-type"                    = "stateless-apps-pool-b"
    "environment"                      = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.spot_node_group_2.name}"
      Environment = var.environment
      Capacity    = "SPOT"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]
}
