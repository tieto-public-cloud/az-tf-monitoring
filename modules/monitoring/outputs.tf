output "deployed_action_groups" {
  value = values(azurerm_monitor_action_group.action_group)[*].id
}

output "deployed_metric_alerts" {
  value = values(azurerm_monitor_metric_alert.metric_alert)[*].id
}

output "deployed_query_alerts" {
  value = values(azurerm_monitor_scheduled_query_rules_alert.query_alert)[*].id
}
