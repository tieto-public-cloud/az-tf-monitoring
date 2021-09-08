terraform {
  backend "azurerm" {
    resource_group_name  = "tstate"
    storage_account_name = "tstate12399"
    container_name       = "tstate-mondev"
    key                  = "terraform.tfstate"
    access_key           = "chbeYCgEGXeb5lhr4gsK4bX0F82MTUSt3pyDTjONiB4MiaUx+6qV/xeIrlkrYXbaTzVQY43CLNI/VBomvigZCA=="
  }
}