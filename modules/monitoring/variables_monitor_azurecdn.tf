#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_azurecdn" {
  description = "Whether to deploy Monitoring alerts related to Azure CDN"
  type        = bool
  default     = false
}

locals {
  azurecdn_query  = merge(var.azurecdn_query, var.azurecdn_custom_query)
}

variable "azurecdn_query" {
  description = "Azure CDN Monitor config for query based monitoring"
  default = {
    "AzureCDN-RequestCountHttpStatus4xx-Critical" = {
      name         = "Azure CDN - RequestCountHttpStatus4xx - Critical"
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
    "Azure CDN-RequestCountHttpStatus4xx-Warning" = {
      name         = "Azure CDN - RequestCountHttpStatus4xx - Warning"
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
    "AzureCDN-RequestCountHttpStatus5xx-Critical" = {
      name         = "Azure CDN - RequestCountHttpStatus5xx - Critical"
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
    "Azure CDN-RequestCountHttpStatus5xx-Warning" = {
      name         = "Azure CDN - RequestCountHttpStatus5xx - Warning"
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

variable "azurecdn_custom_query" {
  description = "Azure CDN Monitor config for query based monitoring - custom"
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