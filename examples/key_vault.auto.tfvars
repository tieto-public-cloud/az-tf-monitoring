/*
query_alert_default = {
  "Key-vault-Overall Vault Availability" = {
    name         = "Key-vault-Overall Vault Availability"
    query        = "AzureMetrics | where MetricName contains 'Availability'| summarize AggregatedValue = max(Maximum)by bin(TimeGenerated, 10h), Resource"
    severity     = 0
    frequency    = 5
    time_window  = 5
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "LessThan"
      threshold = 100
      metric_trigger = {
        operator  = "LessThan"
        threshold = 5
        type      = "Total"
        column    = "Resource"
      }
    }
  }
}
*/