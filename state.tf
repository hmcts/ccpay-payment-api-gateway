terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.20.0"
    }
  }
}
provider "azurerm" {
  features {}
}
