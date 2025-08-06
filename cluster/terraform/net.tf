resource "azurerm_resource_group" "nodepool" {
  name     = var.nodepool_resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.cluster_name}-vnet"
  address_space       = ["10.224.0.0/12"]
  location            = var.location
  resource_group_name = azurerm_resource_group.nodepool.name
  tags                = local.tags
}

resource "azurerm_subnet" "aks_system" {
  name                 = "${local.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.nodepool.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.224.0.0/16"]
}

resource "azurerm_subnet" "aks_user" {
  name                 = "${local.cluster_name}-user-subnet"
  resource_group_name  = azurerm_resource_group.nodepool.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.225.0.0/16"]
}

resource "azurerm_subnet" "virtual_nodes_subnet" {
  name                 = "${local.cluster_name}-virtual-nodes-subnet"
  resource_group_name  = azurerm_resource_group.nodepool.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.226.0.0/16"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
