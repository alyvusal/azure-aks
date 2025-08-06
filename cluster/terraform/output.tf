output "location" {
  value = azurerm_resource_group.aks.location
}

output "resource_group_id" {
  value = azurerm_resource_group.aks.id
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "azure_ad_group_id" {
  value = var.rbac.enabled && length(azuread_group.aks_administrators) > 0 ? azuread_group.aks_administrators[0].id : null
}

output "azure_ad_group_objectid" {
  value = var.rbac.enabled && length(azuread_group.aks_administrators) > 0 ? azuread_group.aks_administrators[0].object_id : null
}

################################################################
#               AKS
################################################################
# output "aks_versions" {
#   value = data.azurerm_kubernetes_service_versions.current.versions
# }

output "aks_latest_version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.self.kubernetes_version
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.self.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.self.name
}

# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].client_certificate
#   sensitive = true
# }

# output "client_key" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].client_key
#   sensitive = true
# }

# output "cluster_ca_certificate" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].cluster_ca_certificate
#   sensitive = true
# }

# output "cluster_password" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].password
#   sensitive = true
# }

# output "cluster_username" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].username
#   sensitive = true
# }

# output "host" {
#   value     = azurerm_kubernetes_cluster.self.kube_config[0].host
#   sensitive = true
# }

# output "kube_config" {
#   value     = azurerm_kubernetes_cluster.self.kube_config_raw
#   sensitive = true
# }
