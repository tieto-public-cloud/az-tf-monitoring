#
# Azure Monitor action group configurations
#
variable "deploy_monitoring_azurevm" {
  description = "Whether to deploy Monitoring alerts related to Azure VM"
  type        = bool
  default     = false
}

locals {
  azurevm_query = merge(var.azurevm_query, var.azurevm_custom_query)
}

variable "azurevm_query" {
  description = "Azure VM Monitor config for query based monitoring"
  default = {
    "AzureVM-CPUUsage-Critical" = {
      name         = "Azure VM - CPU Usage - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
      severity     = 0
      frequency    = 5
      time_window  = 15
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
    "AzureVM-CPUUsage-Warning" = {
      name         = "Azure VM - CPU Usage - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)) ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)) ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
      severity     = 0
      frequency    = 5
      time_window  = 60
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    }
    "AzureVM-AgentUnreachable-Warning" = {
      name         = "Azure VM - Agent Unreachable - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
      severity     = 1
      frequency    = 5
      time_window  = 60
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    }
  }
  type = map(
    object({
      name         = string
      enabled      = optional(bool)
      query        = string
      severity     = optional(number)
      frequency    = number
      time_window  = number
      action_group = string
      throttling   = optional(number)
      trigger = object({
        operator  = string
        threshold = number
        metric_trigger = optional(object({
          operator  = string
          threshold = string
          type      = string
          column    = string
        }))
      })
    })
  )
}

variable "azurevm_custom_query" {
  description = "Azure VM Monitor config for query based monitoring - custom"
  default     = null
  type = map(
    object({
      name         = string
      enabled      = optional(bool)
      query        = string
      severity     = optional(number)
      frequency    = number
      time_window  = number
      action_group = string
      throttling   = optional(number)
      trigger = object({
        operator  = string
        threshold = number
        metric_trigger = optional(object({
          operator  = string
          threshold = string
          type      = string
          column    = string
        }))
      })
    })
  )
}
