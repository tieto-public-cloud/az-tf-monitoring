#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_agw" {
  description = "Whether to deploy Monitoring alerts related to Application Gateway"
  type        = bool
  default     = false
}

variable "agw-query" {
  description = "Application Gateway Monitor config for query based monitoring"
  default = {
    query_alert_default = {
      "AppGW-CPUUsage-Critical" = {
        name         = "Application Gateway - Unhealthy Backend Count - Warning"
        query        = "Placeholder"
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
      "AppGW-CPUUsage-Warning" = {
        name         = "Application Gateway - Backend HTTP 4xx - Warning"
        query        = "Placeholder"
        severity     = 1
        frequency    = 30
        time_window  = 60
        action_group = "tm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 10
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Consecutive"
            column    = "Resource"
          }
        }
      }
      "AppGW-FailedPipelineRuns-Critical" = {
        name         = "Application Gateway - Backend HTTP 5xx - Warning"
        query        = "Placeholder"
        severity     = 1
        frequency    = 30
        time_window  = 60
        action_group = "tm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 10
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