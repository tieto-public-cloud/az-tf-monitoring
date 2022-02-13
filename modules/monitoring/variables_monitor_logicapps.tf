variable "monitor_logicapp" {
  description = "Deploy monitoring for Azure Logic App"
  type        = bool
  default     = false
}

variable "logicapp_log_signals" {
  description = "Additional Azure Logic App configuration for query based monitoring to exetend the default configuration of the module"
  default     = []
  type = list(
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
  logicapp_log_signals_default = [
    {
      name         = "Logic App - Runs Failed - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where ResourceProvider == 'MICROSOFT.LOGIC' and MetricName == 'RunsFailed'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = sum(Total) by bin(TimeGenerated, 5m), Resource"
      severity     = 0
      frequency    = 15
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 2
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    },
    {
      name         = "Logic App - Runs Failed - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where ResourceProvider == 'MICROSOFT.LOGIC' and MetricName == 'RunsFailed'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = sum(Total) by bin(TimeGenerated, 5m), Resource"
      severity     = 1
      frequency    = 15
      time_window  = 30
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
  ]

  logicapp_log_signals = concat(local.logicapp_log_signals_default, var.logicapp_log_signals)
}
