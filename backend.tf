terraform {
  backend "azurerm" {
    resource_group_name  = "tstate"
    storage_account_name = "tstate12399"
    container_name       = "tstate-mondev"
    key                  = "terraform.tfstate"
  }
}