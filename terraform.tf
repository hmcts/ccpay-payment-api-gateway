provider "azurerm" {
  alias           = "aks-cftapps"
  features {}
}

terraform {
  required_version = ">= 1.3.99"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.93.0"
    }
  }
}