variable "lb_log_signals" {
  description = "Additional Load Balancer (Standard SKU) configuration for query based monitoring to exetend the default configuration of the module"
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
  lb_log_signals_default = [
    {
      name         = "Load Balancer (Standard SKU) - Health Percentage - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'VipAvailability' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize by AggregatedValue = Average, bin(TimeGenerated, 5m), Resource"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 90
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    },
    {
      name         = "Load Balancer (Standard SKU) - Health Percentage - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AzureMetrics | where MetricName == 'VipAvailability' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize by AggregatedValue = Average, bin(TimeGenerated, 5m), Resource"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 100
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
  ]

  lb_log_signals = concat(local.lb_log_signals_default, var.lb_log_signals)
}
