#
# Terraform requirements
#
terraform {
  experiments = [module_variable_optional_attrs]

  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "target"
  subscription_id = var.target_subscription_id
  features {}
}