#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_azurefunction" {
  description = "Whether to deploy Monitoring alerts related to Azure Function"
  type        = bool
  default     = false
}

variable "azurefunction-query" {
  description = "Azure Function Monitor config for query based monitoring"
  default = {
    query_alert_default = {
      "AzureFunction-Errors-Critical" = {
        name         = "Azure Function - Errors - Critical"
        query        = "Placeholder"
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
            column    = "Resource"
          }
        }
      }
      "AzureFunction-Errors-Warning" = {
        name         = "Azure Function - Errors - Warning"
        query        = "Placeholder"
        severity     = 1
        frequency    = 5
        time_window  = 5
        action_group = "tm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 60
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