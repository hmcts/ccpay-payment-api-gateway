terraform {
  required_version = ">= 1.3.7"
}

provider "azurerm" {
  alias = "cftappsdemo"
  features {}
  subscription_id = var.aks_subscription_id
}