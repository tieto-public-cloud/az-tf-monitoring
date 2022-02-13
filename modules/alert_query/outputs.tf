output "deployed_query_alerts" {
  value = values(azurerm_monitor_scheduled_query_rules_alert.query_alert)[*].id
}
