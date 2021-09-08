#
# Azure Monitor action group configurations
#
variable "deploy_monitoring_azurevm" {
  description = "Whether to deploy Monitoring alerts related to Azure VM"
  type        = bool
  default     = false
}

variable "azurevm-query" {
  description = "Azure VM Monitor Config for Query based monitoring"
  default = {
    query_alert_default = {
      "AzureVM-CPUUsage-Critical" = {
        name         = "Azure VM - CPU Usage - Critical"
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)) ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)) ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
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
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
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
  }
  type = object({
    query_alert_default = map(
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
  })
}

# variable "azurevm-metric" {
#   description = "Azure VM Monitor Config - metric based monitoring"
#   default = {
#     metric_alert_default = {
#       "Vm-CPUCreditConsumed-Critical" = {
#         enabled                  = true
#         auto_mitigate            = true
#         description              = "Total number of credits consumed by the Virtual Machine"
#         frequency                = "PT15M"
#         severity                 = 0
#         target_resource_type     = "Microsoft.Compute/virtualMachines"
#         action_group             = "tm_critical_action_group_metric"
#         target_resource_location = "westeurope"
#         window_size              = "PT30M"
#         scope                    = var.resource_group_name
#         criteria = {
#           metric_namespace = "Microsoft.Compute/virtualMachines"
#           metric_name      = "CPU Credits Consumed"
#           aggregation      = "Count"
#           operator         = "GreaterThan"
#           threshold        = 100
#         }
#       }
#     }
#   }
#   type = object({
#     metric_alert_default = map(
#       object({
#         enabled                  = optional(bool)
#         auto_mitigate            = optional(bool)
#         description              = optional(string)
#         frequency                = optional(string)
#         severity                 = optional(number)
#         target_resource_type     = optional(string)
#         target_resource_location = optional(string)
#         window_size              = optional(string)
#         action_group             = string
#         scope                    = optional(string)
#         criteria = optional(object({
#           metric_namespace = string
#           metric_name      = string
#           aggregation      = string
#           operator         = string
#           threshold        = number
#           dimension = optional(object({
#             name     = string
#             operator = string
#             values   = list(string)
#           }))
#           skip_metric_validation = optional(bool)
#         }))
#         dynamic_criteria = optional(object({
#           metric_namespace  = string
#           metric_name       = string
#           aggregation       = string
#           operator          = string
#           alert_sensitivity = string
#           dimension = optional(object({
#             name     = string
#             operator = string
#             values   = list(string)
#           }))
#           evaluation_total_count   = optional(number)
#           evaluation_failure_count = optional(number)
#           ignore_data_before       = optional(string)
#           skip_metric_validation   = optional(bool)
#         }))
#         application_insights_web_test_location_availability_criteria = optional(object({
#           web_test_id           = string
#           component_id          = string
#           failed_location_count = number
#         }))
#       })
#     )
#   })
# }