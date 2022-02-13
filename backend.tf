# Declare backend used for TF state storage.
#
# See https://www.terraform.io/language/settings/backends/azurerm for details on how to
# properly configure authentication without inlining credentials here!

# For testing purposes, keeping commented out, using local tfstate.
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "mgmthub-shared"
#     storage_account_name = "tfstate-shared"
#     container_name       = "tfstate-az-tf-monitoring"
#     key                  = "terraform.tfstate"
#   }
# }
