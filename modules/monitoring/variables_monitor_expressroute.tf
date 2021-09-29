#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_expressroute" {
  description = "Whether to deploy Monitoring alerts related to Express Route"
  type        = bool
  default     = false
}

locals {
  expressroute_query  = merge(var.expressroute_query, var.expressroute_custom_query)
}

variable "expressroute_query" {
  description = "Express Route Monitor config for query based monitoring"
  default = {
    "ExpressRoute-AdminState-Critical" = {
      name         = "Express Route - Admin State - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 1
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "Express Route-LineProtocol-Warning" = {
      name         = "Express Route - Line Protocol - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 1
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

variable "expressroute_custom_query" {
  description = "Express Route Monitor config for query based monitoring - custom"
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