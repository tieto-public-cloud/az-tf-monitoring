#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_aci" {
  description = "Whether to deploy Monitoring alerts related to Azure Container Instances"
  type        = bool
  default     = false
}

variable "aci-query" {
  description = "Azure Container Instances Monitor config for query based monitoring"
  default = {
    query_alert_default = {
      "ContainerInstances-MemoryUsage-Critical" = {
        name         = "Container Instances - Memory Usage - Critical"
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
      "ContainerInstances-MemoryUsage-Warning" = {
        name         = "Container Instances - Memory Usage - Warning"
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
      "ContainerInstances-CpuUsage-Critical" = {
        name         = "Container Instances - CPU Usage - Critical"
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
      "ContainerInstances-CpuUsage-Warning" = {
        name         = "Container Instances - CPU Usage - Warning"
        query        = "Placeholder"
        severity     = 1
        frequency    = 5
        time_window  = 15
        action_group = "tm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 90
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 1
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