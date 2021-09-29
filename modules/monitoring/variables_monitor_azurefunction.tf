#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_azurefunction" {
  description = "Whether to deploy Monitoring alerts related to Azure Function"
  type        = bool
  default     = false
}

locals {
  azurefunction_query  = merge(var.azurefunction_query, var.azurefunction_custom_query)
}

variable "azurefunction_query" {
  description = "Azure Function Monitor config for query based monitoring"
  default = {
    "AzureFunction-Errors-Critical" = {
      name         = "Azure Function - Errors - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AppExceptions ; _perf | join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = count() by bin(TimeGenerated, 5m), AppRoleName"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 80
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "AppRoleName"
        }
      }
    }
    "AzureFunction-Errors-Warning" = {
      name         = "Azure Function - Errors - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AppExceptions ; _perf | join kind=inner _resources on $left._ResourceId == $right.Id_s | summarize AggregatedValue = count() by bin(TimeGenerated, 5m), AppRoleName"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 30
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "AppRoleName"
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

variable "azurefunction_custom_query" {
  description = "Azure Function Monitor config for query based monitoring - custom"
  default = null
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