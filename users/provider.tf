terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  use_cli             = true
  storage_use_azuread = true
}