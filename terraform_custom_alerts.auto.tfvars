# this is an example custom alert definition file

azurevm_custom_query = {
  # Adding new custom alert for Azure VM
  "AzureVM-CPUUsageCustomExample-Critical" = {
    name         = "Azure VM - CPU Usage Custom Example - Critical"
    query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 0
    frequency    = 5
    time_window  = 15
    enabled      = true
    action_group = "tm-critical-actiongroup"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 2
        type      = "Consecutive"
        column    = "Computer"
      }
    }
  }
  # Custom override example - disabling this Alert - setting enabled = false
  "AzureVM-CPUUsage-Critical" = {
    name         = "Azure VM - CPU Usage - Critical"
    query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 0
    frequency    = 5
    time_window  = 15
    enabled      = true
    action_group = "tm-critical-actiongroup"
    trigger = {
      operator  = "GreaterThan"
      threshold = 0
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Consecutive"
        column    = "Computer"
      }
    }
  }
}

custom_metric_alerts = {
  "bartpdav-test" = {
    enabled                  = true
    auto_mitigate            = true
    description              = "Total number of credits consumed by the Virtual Machine"
    frequency                = "PT5M"
    severity                 = 0
    target_resource_type     = "Microsoft.Compute/virtualMachines"
    action_group             = "tm-warning-metric-actiongroup"
    target_resource_location = "westeurope"
    scope                    = "/subscriptions/3a60e7b7-ac49-45d8-8a8f-ba61cdc5dc1f/resourceGroups/bartpdav_dev_westeurope_rg"
    window_size              = "PT5M"
    criteria = {
      metric_namespace = "Microsoft.Compute/virtualMachines"
      metric_name      = "CPU Credits Consumed"
      aggregation      = "Count"
      operator         = "GreaterThan"
      threshold        = 100
    }
  }
  "bartpdav-test2" = {
    enabled                  = true
    auto_mitigate            = true
    description              = "Total number of credits consumed by the Virtual Machine"
    frequency                = "PT5M"
    severity                 = 0
    target_resource_type     = "Microsoft.Compute/virtualMachines"
    action_group             = "tm-warning-metric-actiongroup"
    target_resource_location = "westeurope"
    scope                    = "/subscriptions/3a60e7b7-ac49-45d8-8a8f-ba61cdc5dc1f"
    window_size              = "PT5M"
    criteria = {
      metric_namespace = "Microsoft.Compute/virtualMachines"
      metric_name      = "CPU Credits Consumed"
      aggregation      = "Count"
      operator         = "GreaterThan"
      threshold        = 50
    }
  }
}