terraform {
  backend "azurerm" {}

  required_providers {
    provider "azurerm" {
      alias           = "aks-cftapps"
      subscription_id = var.aks_subscription_id
      source          = "hashicorp/azurerm"
      features {}
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
