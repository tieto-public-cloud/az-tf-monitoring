# Declare TF version requirements, features, and module version requirements.
terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.59"
    }
  }
}
