variable "deploy_monitoring_agw" {
  description = "Whether to deploy Monitoring alerts related to Application Gateway"
  type        = bool
  default     = false
}

locals {
  agw_query = merge(var.agw_query, var.agw_custom_query)
}

variable "agw_query" {
  description = "Application Gateway Monitor config for query based monitoring"
  default = {
    "AppGW-UnhealthyBackendCount-Warning" = {
      name         = "Application Gateway - Unhealthy Backend Count - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'UnhealthyHostCount'; _perf | join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Count) by bin(TimeGenerated, 5m), Resource"
      severity     = 1
      frequency    = 30
      time_window  = 60
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "AppGW-ClientRtt-Warning" = {
      name         = "Application Gateway - Client Round Trip Latency - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'ClientRtt'; _perf | join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = avg(Average) by bin(TimeGenerated, 5m), Resource"
      severity     = 1
      frequency    = 30
      time_window  = 60
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 1000
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
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

variable "agw_custom_query" {
  description = "Azure Application Gateway Monitor config for query based monitoring - custom"
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