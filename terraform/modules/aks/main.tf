# ==============================================================================
# AZURE AKS (AZURE KUBERNETES SERVICE) REUSABLE TERRAFORM MODULE
# ==============================================================================
# Target K8s Version: 1.36
# Features:
#   - Deployed in 3 Availability Zones across Private VNet Subnets
#   - System Node Pool (On-Demand Scale Set for Core Services)
#   - 2 Additional User Node Pools (1 Spot Scale Set, 1 On-Demand Scale Set)
#   - Azure Workload Identity & OIDC Issuer Enabled (Azure equivalent of IRSA)
#   - 100% Parameterized, Production Ready, Fully Commented
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. USER ASSIGNED MANAGED IDENTITY FOR AKS CONTROL PLANE & KUBELET
# ------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-identity"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# 2. AZURE KUBERNETES SERVICE (AKS) CLUSTER PROVISIONING
# ------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Workload Identity & OIDC Issuer enable passwordless authentication for pods
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Assign System-Assigned / User-Assigned Identity to Control Plane
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # --- Primary System Node Pool (On-Demand, High-Availability Across Zones 1,2,3) ---
  default_node_pool {
    name                = var.system_node_pool.name
    vm_size             = var.system_node_pool.vm_size
    node_count          = var.system_node_pool.node_count
    enable_auto_scaling = var.system_node_pool.enable_auto_scaling
    min_count           = var.system_node_pool.min_count
    max_count           = var.system_node_pool.max_count
    os_disk_size_gb     = var.system_node_pool.os_disk_size_gb
    vnet_subnet_id      = var.vnet_subnet_id
    zones               = var.system_node_pool.zones
    type                = "VirtualMachineScaleSets"

    # System node labels & taints
    node_labels = {
      "node.kubernetes.io/capacity-type" = "ON_DEMAND"
      "workload-type"                    = "system-core"
      "environment"                      = var.environment
    }
  }

  # Advanced Azure CNI Networking Configuration
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure" # Integrated Azure Network Security Policies
    pod_cidr          = var.pod_cidr
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = "standard"
  }

  # Dynamic AGIC (Application Gateway Ingress Controller) Addon integration
  dynamic "ingress_application_gateway" {
    for_each = var.app_gateway_id != null ? [1] : []
    content {
      gateway_id = var.app_gateway_id
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
      Role        = "Kubernetes-DR-Cluster"
    }
  )
}

# ------------------------------------------------------------------------------
# 3. USER NODE POOL 1: AZURE SPOT VIRTUAL MACHINE SCALE SET
# ------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "spot_user_pool" {
  name                  = var.spot_user_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.spot_user_node_pool.vm_size
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = var.spot_user_node_pool.zones
  os_disk_size_gb       = var.spot_user_node_pool.os_disk_size_gb

  # Enable Spot VM Priority
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = var.spot_user_node_pool.max_price # -1 uses on-demand price limit

  # Auto-scaling configuration for Spot scale set
  enable_auto_scaling = true
  node_count          = var.spot_user_node_pool.desired_count
  min_count           = var.spot_user_node_pool.min_count
  max_count           = var.spot_user_node_pool.max_count

  # Node labels & taints for spot scheduling target
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
    "node.kubernetes.io/capacity-type"      = "SPOT"
    "workload-type"                         = "stateless-dr-pool-a"
    "environment"                           = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.spot_user_node_pool.name}"
      Environment = var.environment
      Capacity    = "SPOT"
    }
  )
}

# ------------------------------------------------------------------------------
# 4. USER NODE POOL 2: AZURE ON-DEMAND VIRTUAL MACHINE SCALE SET
# ------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "ondemand_user_pool" {
  name                  = var.ondemand_user_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.ondemand_user_node_pool.vm_size
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = var.ondemand_user_node_pool.zones
  os_disk_size_gb       = var.ondemand_user_node_pool.os_disk_size_gb

  # On-Demand Priority
  priority = "Regular"

  # Auto-scaling configuration for On-demand scale set
  enable_auto_scaling = true
  node_count          = var.ondemand_user_node_pool.desired_count
  min_count           = var.ondemand_user_node_pool.min_count
  max_count           = var.ondemand_user_node_pool.max_count

  # Node labels for on-demand scheduling target
  node_labels = {
    "node.kubernetes.io/capacity-type" = "ON_DEMAND"
    "workload-type"                    = "stateless-dr-pool-b"
    "environment"                      = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${var.ondemand_user_node_pool.name}"
      Environment = var.environment
      Capacity    = "ON_DEMAND"
    }
  )
}
