# Initialize the AzureRM resource provider(s) used by the underlying modules to provision resources.

# One provider representing the subscription hosting the shared monitoring hub.
provider "azurerm" {
  features {}

  client_id     = var.azurerm_client_id
  client_secret = var.azurerm_client_secret
  tenant_id     = var.azurerm_tenant_id

  subscription_id = var.law_subscription_id

  alias = "law"
}

# One provider representing the subscription that should host the supporting functions.
provider "azurerm" {
  features {}

  client_id     = var.azurerm_client_id
  client_secret = var.azurerm_client_secret
  tenant_id     = var.azurerm_tenant_id

  subscription_id = var.aux_subscription_id

  alias = "aux"
}
