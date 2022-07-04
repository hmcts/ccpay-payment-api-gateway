provider "azurerm" {
  alias = "cftappsdemo"
  features {}
  subscription_id = "d025fece-ce99-4df2-b7a9-b649d3ff2060"
}

terraform {
  required_version = ">= 0.14"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.55.0"
    }
  }
}