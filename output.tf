/*
output "Warning_action_group_id" {
  value = azurerm_monitor_action_group.tm_warn_ag.id
}

output "Critical_action_group_id" {
  value = azurerm_monitor_action_group.action_group[each.value.query_alert.action_group].id
}
*/
output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = local.resource_group_name
}

output "log_analytics_workspace_id" {
  description = "log analytics workspace id"
  value       = local.log_analytics_workspace_id
}

output "available_subscriptions" {
  value = data.azurerm_subscriptions.available.subscriptions
}