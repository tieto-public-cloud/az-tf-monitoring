output "logic_app_principal_id" {
  value = azurerm_logic_app_workflow.tagging_logic_app.identity[0].principal_id
}

output "logic_app_id" {
  value = azurerm_logic_app_workflow.tagging_logic_app.id
}

output "law_id" {
  value = var.law_id
}

output "target_subscription_ids" {
  value = var.target_subscription_ids
}

output "tag_retrieval_interval" {
  value = var.tag_retrieval_interval
}

output "roles_assigned" {
  value = var.assign_roles ? "Yes" : "No"
}
