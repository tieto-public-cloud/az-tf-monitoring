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
    enabled      = false
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
}
