output "deployed_metric_alerts" {
  value = values(azurerm_monitor_metric_alert.metric_alert)[*].id
}
