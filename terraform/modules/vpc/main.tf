# ==============================================================================
# AWS VPC TERRAFORM MODULE - MAIN CONFIGURATION
# ==============================================================================
# Features:
#   - VPC with DNS Support & Hostnames Enabled
#   - 3 PUBLIC Subnets across 3 AZs (Internet-facing)
#   - 3 PRIVATE Subnets across 3 AZs (EKS, RDS, ElastiCache, EC2)
#   - Internet Gateway (IGW) for Public Subnet routing
#   - 3 NAT Gateways with Elastic IPs (1 per AZ for HA) for Private Subnet egress
#   - Route Tables for Public and Private subnets with associations
#   - Dynamic blocks, locals, data sources used throughout
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
# DATA BLOCK: FETCH AVAILABLE AZs IN CURRENT REGION DYNAMICALLY
# ------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# 1. VPC RESOURCE
# ------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true   # Required for EKS, RDS endpoint resolution
  enable_dns_hostnames = true   # Required for EC2 hostname assignment

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}"
    }
  )
}

# ------------------------------------------------------------------------------
# 2. INTERNET GATEWAY (IGW) - ENABLES PUBLIC SUBNET INTERNET ACCESS
# ------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-igw"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. PUBLIC SUBNETS (3 AZs) - cidrsubnet() function from locals.tf
# ------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Allow EC2 instances in public subnets to receive public IPs automatically
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-public-${data.aws_availability_zones.available.names[count.index]}"
      # EKS uses these tags to discover subnets for load balancer provisioning
      "kubernetes.io/role/elb" = "1"
    }
  )
}

# ------------------------------------------------------------------------------
# 4. PRIVATE SUBNETS (3 AZs) - cidrsubnet() function from locals.tf
# ------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}"
      # EKS uses these tags to discover subnets for internal load balancer provisioning
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# ------------------------------------------------------------------------------
# 5. ELASTIC IP ADDRESSES FOR NAT GATEWAYS (1 PER AZ)
# ------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count  = local.az_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )
}

# ------------------------------------------------------------------------------
# 6. NAT GATEWAYS (1 PER PUBLIC SUBNET / AZ) - HIGH AVAILABILITY DESIGN
# ------------------------------------------------------------------------------

resource "aws_nat_gateway" "nat" {
  count         = local.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id  # NAT GW lives in PUBLIC subnet

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-nat-gw-az${count.index + 1}"
    }
  )
}

# ------------------------------------------------------------------------------
# 7. PUBLIC ROUTE TABLE WITH IGW ROUTE
# ------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-public-rtb"
    }
  )
}

# Associate ALL 3 public subnets with the single public route table
resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# 8. PRIVATE ROUTE TABLES WITH NAT GATEWAY ROUTES (1 PER AZ FOR HA)
# ------------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id  # Each AZ uses its own NAT GW
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${var.environment}-private-rtb-az${count.index + 1}"
    }
  )
}

# Associate each private subnet with its corresponding AZ-specific private route table
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
