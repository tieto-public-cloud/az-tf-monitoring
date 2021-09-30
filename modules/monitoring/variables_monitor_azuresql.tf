#
# Azure Monitor action group configurations
#
variable "deploy_monitoring_azuresql" {
  description = "Whether to deploy Monitoring alerts related to Azure SQL"
  type        = bool
  default     = false
}

locals {
  azuresql_query = merge(var.azuresql_query, var.azuresql_custom_query)
}

variable "azuresql_query" {
  description = "Azure SQL Monitor config for query based monitoring"
  default = {
    "AzureSQL-DTUUsage-Critical" = {
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
    }
    "AzureSQL-DTUUsage-Warning" = {
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
    }
    "AzureSQL-CPUUsage-Critical" = {
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
    }
    "AzureSQL-CPUUsage-Warning" = {
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
    }
    "AzureSQL-DataSpaceUsed-Critical" = {
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
    }
    "AzureSQL-DataSpaceUsed-Warning" = {
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
    }
    "AzureSQL-DataIOPercentage-Critical" = {
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
    }
    "AzureSQL-DataIOPercentage-Warning" = {
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

variable "azuresql_custom_query" {
  description = "Azure SQL Monitor config for query based monitoring - custom"
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