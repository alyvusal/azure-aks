locals {
  # Naming and tags
  name         = "${var.team}-${var.environment}"
  cluster_name = "${local.name}-${var.cluster_name}"
  tags = {
    owners      = var.team
    environment = var.environment
    # "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    # "karpenter.sh/discovery"                      = "${local.name}-${var.cluster_name}"
  }
  linux_node_pools_labels = {
    "nodepool-type" = "system"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "app"           = "system-apps"
  }

  cluster_version = var.cluster_version == "" ? data.azurerm_kubernetes_service_versions.current.latest_version : var.cluster_version
}
