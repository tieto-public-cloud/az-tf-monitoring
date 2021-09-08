#
# Terraform requirements
#
terraform {
  experiments = [module_variable_optional_attrs]

  required_version = ">=1.0.0"

}

provider "azurerm" {
  features {}
}
