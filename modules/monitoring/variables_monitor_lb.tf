variable "deploy_monitoring_lb" {
  description = "Whether to deploy Monitoring alerts related to Load Balancer (Standard SKU)"
  type        = bool
  default     = false
}

locals {
  lb_query = merge(var.lb_query, var.lb_custom_query)
}

variable "lb_query" {
  description = "Load Balancer (Standard SKU) Monitor config for query based monitoring"
  default = {
    "LoadBalancerStandard-HealthPercentage-Critical" = {
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
    }
    "LoadBalancerStandard-HealthPercentage-Warning" = {
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

variable "lb_custom_query" {
  description = "Load Balancer (Standard SKU) Monitor config for query based monitoring - custom"
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