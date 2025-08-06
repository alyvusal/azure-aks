resource "azurerm_resource_group" "aks" {
  name     = "${var.main_resource_group_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

resource "random_uuid" "aks" {}

resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${var.environment}-logs-${random_uuid.aks.id}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  retention_in_days   = 30
}

# Create Azure AD Group in Active Directory for AKS Admins
resource "azuread_group" "aks_administrators" {
  count = var.rbac.enabled ? 1 : 0

  display_name     = "${local.cluster_name}-administrators"
  security_enabled = true
  description      = "Azure AKS Kubernetes administrators for the ${local.cluster_name}."
}

# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/aci_connector_linux/main.tf#L73
# Managed Identities > aciconnectorlinux-devops-dev-aks > add aciconnectorlinux-devops-dev-aks with below access:
#   Resource type: Microsoft.Network/virtualNetworks/subnets
#   Resource name: devops-dev-aks-vnet/devops-dev-aks-virtual-nodes-subnet
#   Role: Network Contributor
resource "azurerm_role_assignment" "aci_connector_linux" {
  count = var.virtual_nodes.enabled ? 1 : 0

  scope                = azurerm_subnet.virtual_nodes_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.self.aci_connector_linux[0].connector_identity[0].object_id
}

################################################################
#               AKS
################################################################

data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "self" {
  name                         = local.cluster_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.aks.name
  dns_prefix                   = local.cluster_name
  kubernetes_version           = local.cluster_version
  node_resource_group          = "${var.system_pool_resource_group_name}-${var.environment}"
  local_account_disabled       = var.rbac.local_account_disabled
  image_cleaner_interval_hours = 168

  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = local.cluster_version
    zones                = var.zones
    vnet_subnet_id       = azurerm_subnet.aks_system.id
    node_count           = var.autoscaling.enabled ? null : 1 # Create 1 node if autoscale not enabled
    auto_scaling_enabled = var.autoscaling.enabled
    min_count            = var.autoscaling.enabled ? var.autoscaling.min_count : null
    max_count            = var.autoscaling.enabled ? var.autoscaling.max_count : null
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels          = local.linux_node_pools_labels
    tags                 = local.tags
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned" # UserAssigned
  }

  ########################################
  #               Add On Profiles
  ########################################

  azure_policy_enabled             = var.azure_policy_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  dynamic "oms_agent" {
    for_each = var.monitoring.enabled ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
      # Enable MSI  # TODO: clarify what it is
      msi_auth_for_monitoring_enabled = var.monitoring.msi_auth_for_monitoring_enabled
    }
  }

  # Azure authentication with Kubernetes RBAC
  # Create role binding in k8s for Azure AD user to allow manage resources
  role_based_access_control_enabled = var.rbac.enabled # could be switched to Azure RBAC only, but not to local user

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac.enabled ? [1] : []
    content {
      admin_group_object_ids = [azuread_group.aks_administrators[0].object_id]
      # Wnen Azure RBAC enabled, add user to admin group and they will have access
      azure_rbac_enabled = var.rbac.azure_rbac_enabled # Azure authentication with Azure RBAC, can be cahnegd to Kubernetes RBAC only, but not to local user
    }
  }

  ########################################
  #               Node Profiles
  ########################################

  dynamic "linux_profile" {
    for_each = var.linux_profile.enabled ? [1] : []
    content {
      admin_username = var.linux_profile.admin_username
      ssh_key {
        key_data = file(var.linux_profile.ssh_public_key)
      }
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile.enabled ? [1] : []
    content {
      admin_username = var.windows_profile.admin_username
      admin_password = var.windows_profile.admin_password
    }
  }

  # Virtual nodes Profile
  # https://learn.microsoft.com/en-us/azure/aks/virtual-nodes-cli
  dynamic "aci_connector_linux" {
    for_each = var.virtual_nodes.enabled ? [1] : []
    content {
      subnet_name = azurerm_subnet.virtual_nodes_subnet.name
    }
  }

  ########################################
  #               Network Profile
  ########################################
  network_profile {
    network_plugin    = "azure" # kubenet
    load_balancer_sku = "standard"
  }

  tags = local.tags
}

################################################################
#               User Node Pools
################################################################

resource "azurerm_kubernetes_cluster_node_pool" "self" {
  count = var.node_pool.enabled ? 1 : 0

  name                  = "userpool-${var.environment}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.self.id
  vm_size               = "Standard_DS2_v2"
  mode                  = "User"
  node_count            = var.node_pool.auto_scaling_enabled ? null : 1 # Create 1 node if autoscale not enabled
  auto_scaling_enabled  = var.node_pool.auto_scaling_enabled
  min_count             = var.node_pool.auto_scaling_enabled ? var.node_pool.min_count : null
  max_count             = var.node_pool.auto_scaling_enabled ? var.node_pool.max_count : null
  vnet_subnet_id        = azurerm_subnet.aks_user.id
  node_labels           = local.linux_node_pools_labels
  tags                  = local.tags
}
