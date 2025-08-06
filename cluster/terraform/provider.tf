terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

  # Backend resource group, storage account and container created manually
  backend "azurerm" {
    # resource_group_name  = "remote_state"
    # storage_account_name = "terraformremotestateaks"
    # container_name       = "tfstatefiles"
    # key                  = "terraform.tfstate"
    # client_id            = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_CLIENT_ID` environment variable.
    # client_secret        = "************************************"  # Can also be set via `ARM_CLIENT_SECRET` environment variable.
    # subscription_id      = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_SUBSCRIPTION_ID` environment variable.
    # tenant_id            = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_TENANT_ID` environment variable.
  }
}

provider "azurerm" {
  features {
    # resource_group {
    #   prevent_deletion_if_contains_resources = false
    # }
  }
  subscription_id = var.subscription_id
  # client_id       = "00000000-0000-0000-0000-000000000000"
  # client_secret   = var.client_secret
  # tenant_id       = "10000000-0000-0000-0000-000000000000"
}

# TODO: change auth to service principal for backend and tf
