#
# Azure Monitor action group configurations
#
variable "deploy_monitoring_logicapps" {
  description = "Whether to deploy Monitoring alerts related to Logic Apps"
  type        = bool
  default     = false
}

variable "logicapps-query" {
  description = "Logic Apps Monitor config for query based monitoring"
  default = {
    query_alert_default = {
      "LogicApps-RunsFailed-Critical" = {
        name         = "Logic Apps - Runs Failed - Critical"
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
      }
      "LogicApps-RunsFailed-Warning" = {
        name         = "Logic Apps - Runs Failed - Warning"
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