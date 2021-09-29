#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_datafactory" {
  description = "Whether to deploy Monitoring alerts related to Data Factory"
  type        = bool
  default     = false
}

locals {
  datafactory_query  = merge(var.datafactory_query, var.datafactory_custom_query)
}

variable "datafactory_query" {
  description = "Data Factory Monitor config for query based monitoring"
  default = {
    "DataFactory-CPUUsage-Critical" = {
      name         = "Data Factory - CPU Usage - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "DataFactory-CPUUsage-Warning" = {
      name         = "Data Factory - CPU Usage - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 85
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "DataFactory-FailedPipelineRuns-Critical" = {
      name         = "Data Factory - Failed Pipeline Runs - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 1
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "DataFactory-FailedPipelineRuns-Warning" = {
      name         = "Data Factory - Failed Pipeline Runs - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 15
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

variable "datafactory_custom_query" {
  description = "Data Factory Monitor config for query based monitoring - custom"
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