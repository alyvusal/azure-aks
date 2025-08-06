################################################################
#               Global
################################################################

variable "environment" {
  type        = string
  default     = "dev"
}

variable "team" {
  type        = string
  default     = "devops"
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "main_resource_group_name" {
  type        = string
  default     = "aks-main-rg"
}

variable "system_pool_resource_group_name" {
  type        = string
  default     = "aks-systempool-rg"
}

################################################################
#               AKS
################################################################

variable "cluster_name" {
  type        = string
  default     = "aks"
}

variable "cluster_version" {
  type        = string
  default     = ""
}

variable "linux_profile" {
  type = object({
    enabled        = bool
    admin_username = optional(string, "ubuntu")
    ssh_public_key = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {
    enabled = true
  }
}

variable "windows_profile" {
  type = object({
    enabled        = bool
    admin_username = optional(string, "azureuser")
    admin_password = optional(string)
  })
  default = {
    enabled = false
  }
}

variable "zones" {
  type        = list(number)
  default     = [1, 2, 3]
}

variable "autoscaling" {
  type = object({
    enabled   = bool
    min_count = optional(number, 1)
    max_count = optional(number, 3)
  })
  default = {
    enabled = false
  }
}

variable "rbac" {
  type = object({
    # Choose among native Kubernetes RBAC managed locally or leverage Microsoft Entra ID to manage identities for your Kubernetes RBAC needs.
    enabled = bool # Azure authentication with Kubernetes RBAC
    # Azure RBAC for AKS is a fully managed RBAC solution providing both authentication and authorization through Azure IAM.
    azure_rbac_enabled     = optional(bool, false) # Azure authentication with Azure RBAC
    local_account_disabled = optional(bool, false) # if true, can not use admin account, https://learn.microsoft.com/en-us/azure/aks/manage-local-accounts-managed-azure-ad#disable-local-accounts
  })
  default = {
    enabled = false
  }
}

variable "monitoring" {
  type = object({
    enabled                         = bool
    msi_auth_for_monitoring_enabled = optional(bool, false)
  })
  default = {
    enabled = false
  }
}


################################################################
#               Add On Profiles
################################################################

variable "azure_policy_enabled" {
  description = "- (Optional) Should the Azure Policy Add-On be enabled?"
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "- (Optional) Should the Azure Http routing Add-On be enabled?"
  type        = bool
  default     = false
}

variable "virtual_nodes" {
  description = "Enable Virtual nodes Profile"
  type = object({
    enabled     = bool
    subnet_name = optional(string, "virtial-nodes-aci")
  })
  default = {
    enabled = false
  }
}

################################################################
#               (User Workloads) Node Pools
################################################################
variable "nodepool_resource_group_name" {
  type        = string
  description = "This variable defines the Resource Group for Node Group"
  default     = "aks-nodepool-rg"
}

variable "node_pool" {
  description = "Enable user defined node pools"
  type = object({
    enabled              = bool
    auto_scaling_enabled = optional(bool, false)
    min_count            = optional(number, 1)
    max_count            = optional(number, 3)
  })
  default = {
    enabled = false
  }
}
