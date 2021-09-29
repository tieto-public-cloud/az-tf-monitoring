#
# Azure Monitor action group configurations
#

variable "deploy_monitoring_lbadv" {
  description = "Whether to deploy Monitoring alerts related to Advanced Load Balancer"
  type        = bool
  default     = false
}

locals {
  lbadv_query  = merge(var.lbadv_query, var.lbadv_custom_query)
}

variable "lbadv_query" {
  description = "Advanced Load Balancer Monitor config for query based monitoring"
  default = {
    "LoadBalancerAdvanced-HTTPCodeELB4XXCount-Critical" = {
      name         = "Load Balancer Advanced - HTTPCode ELB 4XX Count - Critical"
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
    "LoadBalancerAdvanced-HTTPCodeELB4XXCount-Warning" = {
      name         = "Load Balancer Advanced - HTTPCode ELB 4XX Count - Warning"
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
    "LoadBalancerAdvanced-HTTPCodeELB5XXCount-Critical" = {
      name         = "Load Balancer Advanced - HTTPCode ELB 5XX Count - Critical"
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
    "LoadBalancerAdvanced-HTTPCodeELB5XXCount-Warning" = {
      name         = "Load Balancer Advanced - HTTPCode ELB 5XX Count - Warning"
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
    "LoadBalancerAdvanced-RejectedConnectionCount-Critical" = {
      name         = "Load Balancer Advanced - Rejected Connection Count - Critical"
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
    "LoadBalancerAdvanced-RejectedConnectionCount-Warning" = {
      name         = "Load Balancer Advanced - Rejected Connection Count - Warning"
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
    "LoadBalancerAdvanced-HTTPCodeTarget4XXCount-Critical" = {
      name         = "Load Balancer Advanced - HTTPCode Target 4XX Count - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
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
    "LoadBalancerAdvanced-HTTPCodeTarget4XXCount-Warning" = {
      name         = "Load Balancer Advanced - HTTPCode Target 4XX Count - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 40
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "LoadBalancerAdvanced-HTTPCodeTarget5XXCount-Critical" = {
      name         = "Load Balancer Advanced - HTTPCode Target 5XX Count - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
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
    "LoadBalancerAdvanced-HTTPCodeTarget5XXCount-Warning" = {
      name         = "Load Balancer Advanced - HTTPCode Target 5XX Count - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 40
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "LoadBalancerAdvanced-TargetConnectionErrorCount-Critical" = {
      name         = "Load Balancer Advanced - Target Connection Error Count - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
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
    "LoadBalancerAdvanced-TargetConnectionErrorCount-Warning" = {
      name         = "Load Balancer Advanced - Target Connection Error Count - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 40
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "LoadBalancerAdvanced-BackendConnectionErrors-Critical" = {
      name         = "Load Balancer Advanced - Backend Connection Errors - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
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
    "LoadBalancerAdvanced-BackendConnectionErrors-Warning" = {
      name         = "Load Balancer Advanced - Backend Connection Errors - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 40
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "LoadBalancerAdvanced-ELBLatency-Critical" = {
      name         = "Load Balancer Advanced - LB Latency - Critical"
      query        = "Placeholder"
      severity     = 0
      frequency    = 5
      time_window  = 5
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 50
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Consecutive"
          column    = "Resource"
        }
      }
    }
    "LoadBalancerAdvanced-ELBLatency-Warning" = {
      name         = "Load Balancer Advanced - LB Latency - Warning"
      query        = "Placeholder"
      severity     = 1
      frequency    = 5
      time_window  = 5
      action_group = "tm-warning-actiongroup"
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

variable "lbadv_custom_query" {
  description = "Advanced Load Balancer Monitor config for query based monitoring - custom"
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