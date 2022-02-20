output "logic_app_principal_id" {
  value = azurerm_logic_app_workflow.snow_logic_app.identity[0].principal_id
}

output "logic_app_id" {
  value = azurerm_logic_app_workflow.snow_logic_app.id
}

output "logic_app_callback_url" {
  value = azurerm_logic_app_trigger_http_request.snow_logic_app_http_trigger.callback_url
}

output "roles_assigned" {
  value = var.assign_roles ? "Yes" : "No"
}