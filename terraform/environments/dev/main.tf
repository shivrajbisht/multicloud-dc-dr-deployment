# ==============================================================================
# DEV ENVIRONMENT MAIN TERRAFORM EXECUTION FILE
# ==============================================================================
# Instantiates reusable modules:
#   - Azure Resource Group
#   - AWS VPC & Azure VNet (Networking foundation)
#   - AWS Security Groups & Azure NSG (Network security)
#   - AWS Key Pair, EC2 Bastion & Azure VM Bastion (Compute & Admin access)
#   - AWS ALB & Azure Application Gateway v2 (Public Ingress & SSL Termination)
#   - AWS EKS (Primary DC) & Azure AKS (Secondary DR)
#   - Kafka MM2 & Elasticsearch (Cross-cloud data replication & logging)
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "multicloud-tf-state-dev"
    key            = "dc-dr/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "multicloud-tf-locks-dev"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

# ------------------------------------------------------------------------------
# 0. AZURE RESOURCE GROUP
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.azure_resource_group
  location = var.azure_location
  tags     = local.common_tags
}

# ------------------------------------------------------------------------------
# 1. NETWORKING: AWS VPC & AZURE VNET
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_name    = "vpc-dc-${var.environment}"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
  tags        = local.common_tags
}

module "azure_vnet" {
  source = "../../modules/azure_vnet"

  vnet_name           = "vnet-dr-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  vnet_address_space  = [var.azure_vnet_cidr]
  environment         = var.environment
  tags                = local.common_tags
}

# ------------------------------------------------------------------------------
# 2. SECURITY: AWS SECURITY GROUPS & AZURE NSGs
# ------------------------------------------------------------------------------
module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr
  environment           = var.environment
  bastion_ingress_cidrs = var.bastion_ssh_allowed_cidrs
  tags                  = local.common_tags
}

module "azure_nsg" {
  source = "../../modules/azure_nsg"

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.azure_location
  environment               = var.environment
  vnet_cidr                 = var.azure_vnet_cidr
  bastion_allowed_ssh_cidrs = var.bastion_ssh_allowed_cidrs
  tags                      = local.common_tags
}

# ------------------------------------------------------------------------------
# 3. COMPUTE & SSH: AWS KEY PAIR, EC2 BASTION & AZURE VM BASTION
# ------------------------------------------------------------------------------
module "key_pair" {
  source = "../../modules/key_pair"

  key_name    = "key-dc-${var.environment}"
  environment = var.environment
  tags        = local.common_tags
}

module "ec2_bastion" {
  source = "../../modules/ec2"

  instance_name       = "ec2-bastion-dc-${var.environment}"
  instance_type       = "t3.medium"
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security_groups.bastion_sg_id]
  key_pair_name       = module.key_pair.key_pair_name
  associate_public_ip = true
  environment         = var.environment
  tags                = local.common_tags
}

module "azure_vm_bastion" {
  source = "../../modules/azure_vm"

  vm_name             = "vm-bastion-dr-${var.environment}"
  vm_size             = "Standard_B2s"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  subnet_id           = module.azure_vnet.public_subnet_ids[0]
  nsg_id              = module.azure_nsg.bastion_nsg_id
  associate_public_ip = true
  admin_username      = "azureuser"
  environment         = var.environment
  tags                = local.common_tags
}

# ------------------------------------------------------------------------------
# 4. LOAD BALANCERS: AWS ALB & AZURE APPLICATION GATEWAY V2
# ------------------------------------------------------------------------------
module "alb" {
  source = "../../modules/alb"

  alb_name          = "alb-dc-${var.environment}"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_type       = "ip" # Direct EKS Pod IP routing via AWS Load Balancer Controller
  target_port       = 8080
  health_check_path = "/healthz"
  environment       = var.environment
  tags              = local.common_tags
}

module "azure_app_gateway" {
  source = "../../modules/azure_app_gateway"

  appgw_name          = "appgw-dr-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  subnet_id           = module.azure_vnet.public_subnet_ids[0]
  sku_name            = "Standard_v2"
  capacity            = 2
  health_check_path   = "/healthz"
  environment         = var.environment
  tags                = local.common_tags
}

# ------------------------------------------------------------------------------
# 5. KUBERNETES CLUSTERS: AWS EKS (PRIMARY DC) & AZURE AKS (SECONDARY DR)
# ------------------------------------------------------------------------------
module "eks_dc_cluster" {
  source = "../../modules/eks"

  cluster_name       = "eks-dc-${var.environment}-01"
  cluster_version    = "1.36"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  on_demand_node_group = {
    name           = "ondemand-core"
    instance_types = ["m6i.large"]
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 50
  }

  spot_node_group_1 = {
    name           = "spot-app-a"
    instance_types = ["c6i.large", "c5.large"]
    min_size       = 1
    max_size       = 6
    desired_size   = 2
    disk_size      = 50
  }

  spot_node_group_2 = {
    name           = "spot-app-b"
    instance_types = ["r6i.large", "r5.large"]
    min_size       = 1
    max_size       = 6
    desired_size   = 2
    disk_size      = 50
  }

  tags = merge(local.common_tags, { DC_Role = "Primary-EKS" })
}

module "aks_dr_cluster" {
  source = "../../modules/aks"

  cluster_name        = "aks-dr-${var.environment}-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  kubernetes_version  = "1.36"
  dns_prefix          = "aks-dr-${var.environment}"
  environment         = var.environment
  vnet_subnet_id      = module.azure_vnet.aks_subnet_id

  tags = merge(local.common_tags, { DC_Role = "Secondary-AKS" })
}

# ------------------------------------------------------------------------------
# 6. CROSS-CLOUD REPLICATION & MESSAGING SERVICES
# ------------------------------------------------------------------------------
module "kafka_mm2" {
  source = "../../modules/kafka_mm2"

  environment                 = var.environment
  dc_cluster_bootstrap_server = "kafka-dc.internal:9092"
  dr_cluster_bootstrap_server = "kafka-dr.internal:9092"
  replication_topics_pattern  = "orders-.*|users-.*|payments-.*"
}

module "elasticsearch_cluster" {
  source = "../../modules/elasticsearch"

  environment  = var.environment
  cluster_name = "es-dc-dr-${var.environment}"
  node_count   = 3
  storage_size = "50Gi"
}
