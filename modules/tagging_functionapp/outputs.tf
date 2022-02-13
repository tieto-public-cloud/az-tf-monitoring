output "function_app_principal_id" {
  value = azurerm_function_app.function_app.identity[0].principal_id
}

output "function_app_id" {
  value = azurerm_function_app.function_app.id
}

output "storage_account_id" {
  value = azurerm_storage_account.function_storage.id
}

output "law_id" {
  value = var.law_id
}

output "target_subscription_id" {
  value = var.target_subscription_id
}

output "tag_retrieval_interval" {
  value = var.tag_retrieval_interval
}

output "roles_assigned" {
  value = var.assign_roles ? "Yes" : "No"
}
