query_alert_default = {
  "AzureVM-CPUUsage-Critical" = {
    name         = "Azure VM - CPU Usage - Critical"
    query        = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 0
    frequency    = 5
    time_window  = 15
    action_group = "tm_critical_action_group"
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
  "AzureVM-CPUUsage-Warning" = {
    name         = "Azure VM - CPU Usage - Warning"
    query        = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 1
    frequency    = 5
    time_window  = 15
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 2
        type      = "Consecutive"
        column    = "Computer"
      }
    }
  }
  "AzureVM-MemoryUsage-Critical" = {
    name         = "Azure VM - Memory Usage - Critical"
    query        = "Perf | where ObjectName == 'Memory' and (CounterName == '% Committed Bytes In Use' or CounterName == '% Used Memory') | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 0
    frequency    = 5
    time_window  = 15
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 90
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 1
        type      = "Consecutive"
        column    = "Computer"
      }
    }
  }
  "AzureVM-MemoryUsage-Warning" = {
    name         = "Azure VM - Memory Usage - Warning"
    query        = "Perf | where ObjectName == 'Memory' and (CounterName == '% Committed Bytes In Use' or CounterName == '% Used Memory') | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
    severity     = 1
    frequency    = 5
    time_window  = 15
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 80
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 1
        type      = "Consecutive"
        column    = "Computer"
      }
    }
  }
  "AzureVM-OSDiskFreeSpace-Critical" = {
    name         = "Azure VM - OS Disk Free Space - Critical"
    query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
    severity     = 0
    frequency    = 30
    time_window  = 30
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "LessThan"
      threshold = 10
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Computer"
      }
    }
  }
  "AzureVM-OSDiskFreeSpace-Warning" = {
    name         = "Azure VM - OS Disk Free Space - Warning"
    query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
    severity     = 1
    frequency    = 30
    time_window  = 30
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "LessThan"
      threshold = 20
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Computer"
      }
    }
  }
  "AzureVM-DataDiskFreeSpace-Critical" = {
    name         = "Azure VM - Data Disk Free Space - Critical"
    query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
    severity     = 0
    frequency    = 30
    time_window  = 30
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "LessThan"
      threshold = 15
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Computer"
      }
    }
  }
  "AzureVM-DataDiskFreeSpace-Warning" = {
    name         = "Azure VM - Data Disk Free Space - Warning"
    query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
    severity     = 1
    frequency    = 30
    time_window  = 30
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "LessThan"
      threshold = 5
      metric_trigger = {
        operator  = "GreaterThan"
        threshold = 0
        type      = "Total"
        column    = "Computer"
      }
    }
  }
  "AzureVM-DiskUsedSpace-Critical" = {
    name         = "Azure VM - Disk Used Space - Critical"
    query        = "Perf | where ObjectName == 'Logical Disk' and CounterName == '% Used Space' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        column    = "Computer"
      }
    }
  }
  "AzureVM-DiskUsedSpace-Warning" = {
    name         = "Azure VM - Disk Used Space - Warning"
    query        = "Perf | where ObjectName == 'Logical Disk' and CounterName == '% Used Space' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        column    = "Computer"
      }
    }
  }
  "AzureVM-AgentUnreachable-Critical" = {
    name         = "Azure VM - Agent Unreachable - Critical"
    query        = "Heartbeat | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
    severity     = 0
    frequency    = 5
    time_window  = 60
    action_group = "tm_critical_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 0
    }
  }
  "AzureVM-AgentUnreachable-Warning" = {
    name         = "Azure VM - Agent Unreachable - Warning"
    query        = "Heartbeat | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
    severity     = 1
    frequency    = 5
    time_window  = 60
    action_group = "tm_warning_action_group"
    trigger = {
      operator  = "GreaterThan"
      threshold = 0
    }
  }
}

metric_alert_default = {
  "Vm-CPUCreditConsumed-Critical" = {
    enabled                  = true
    auto_mitigate            = true
    description              = "Total number of credits consumed by the Virtual Machine"
    frequency                = "PT15M"
    severity                 = 0
    target_resource_type     = "Microsoft.Compute/virtualMachines"
    action_group             = "tm_critical_action_group"
    target_resource_location = "westeurope"
    window_size              = "PT30M"
    criteria = {
      metric_namespace = "Microsoft.Compute/virtualMachines"
      metric_name      = "CPU Credits Consumed"
      aggregation      = "Count"
      operator         = "GreaterThan"
      threshold        = 100
    }
  }
}