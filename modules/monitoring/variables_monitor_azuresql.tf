variable "monitor_azuresql" {
  description = "Deploy monitoring for Azure SQL"
  type        = bool
  default     = false
}

variable "azuresql_log_signals" {
  description = "Additional Azure SQL configuration for query based monitoring to exetend the default configuration of the module"
  default     = []
  type        = list(
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

locals {
  azuresql_log_signals_default = [
    {
      name         = "Azure SQL - DTU Usage - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'dtu_consumption_percent'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - DTU Usage - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'dtu_consumption_percent'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - CPU Usage - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'cpu_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - CPU Usage - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'cpu_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - Data Space Used - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'storage_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 30m), Resource"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"

      trigger = {
        operator  = "GreaterThan"
        threshold = 90

        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 2
          type      = "Total"
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - Data Space Used - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'storage_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 30m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - Data IO Percentage - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'physical_data_read_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    },
    {
      name         = "Azure SQL - Data IO Percentage - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'physical_data_read_percent' and ResourceProvider == 'MICROSOFT.SQL'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
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
          column    = "Resource"
        }
      }
    }
  ]

  azuresql_log_signals = concat(local.azuresql_log_signals_default, var.azuresql_log_signals)
}
