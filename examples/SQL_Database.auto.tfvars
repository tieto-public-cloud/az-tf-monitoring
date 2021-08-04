query_alert_local = {
  "AzureSQL-DTUUsage-Critical" = {
    name         = "AzureSQL-DTUUsage-Critical"
    query        = "AzureMetrics | where MetricName == 'dtu_consumption_percent' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 0
    frequency    = 5
    time_window  = 15
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-DTUUsage-Warning" = {
    name         = "AzureSQL-DTUUsage-Warning"
    query        = "AzureMetrics | where MetricName == 'dtu_consumption_percent' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 1
    frequency    = 5
    time_window  = 15
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-CPUUsage-Critical" = {
    name         = "AzureSQL-CPUUsage-Critical"
    query        = "AzureMetrics | where MetricName == 'cpu_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 0
    frequency    = 5
    time_window  = 15
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-CPUUsage-Warning" = {
    name         = "AzureSQL-CPUUsage-Warning"
    query        = "AzureMetrics | where MetricName == 'cpu_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 1
    frequency    = 5
    time_window  = 15
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-DataSpaceUsed-Critical" = {
    name         = "AzureSQL-DataSpaceUsed-Critical"
    query        = "AzureMetrics | where MetricName == 'storage_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 30m), Resource"
    severity     = 0
    frequency    = 30
    time_window  = 30
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-DataSpaceUsed-Warning" = {
    name         = "AzureSQL-DataSpaceUsed-Warning"
    query        = "AzureMetrics | where MetricName == 'storage_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 30m), Resource"
    severity     = 1
    frequency    = 30
    time_window  = 30
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-DataIOPercentage-Critical" = {
    name         = "AzureSQL-DataIOPercentage-Critical"
    query        = "AzureMetrics | where MetricName == 'physical_data_read_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 0
    frequency    = 5
    time_window  = 15
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
  "AzureSQL-DataIOPercentage-Warning" = {
    name         = "AzureSQL-DataIOPercentage-Warning"
    query        = "AzureMetrics | where MetricName == 'physical_data_read_percent' and ResourceProvider == 'MICROSOFT.SQL' | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
    severity     = 1
    frequency    = 5
    time_window  = 15
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 5
        type      = "Consecutive"
        column    = "Resource"
      }
    }
  }
}

metric_alert_local = {
  "SQL-DB-CPUpercentage-Critical" = {
    enabled                  = true
    auto_mitigate            = true
    description              = "CPU percentage"
    frequency                = "PT5M"
    severity                 = 0
    target_resource_type     = "Microsoft.Sql/servers/databases"
    action_group             = "tm_critical_action_group"
    target_resource_location = "westeurope"
    window_size              = "PT15M"
    criteria = {
      metric_namespace = "Microsoft.Sql/servers/databases"
      metric_name      = "cpu_percent"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 90
    }
  }
}