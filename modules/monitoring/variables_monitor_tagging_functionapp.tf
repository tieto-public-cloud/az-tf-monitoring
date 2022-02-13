variable "monitor_tagging_functionapp" {
  description = "Deploy monitoring for supporting functionality introduced by this module"
  type        = bool
  default     = true
}

variable "tagging_functionapp_log_signals" {
  description = "Additional Tagging Function App configuration for query based monitoring to exetend the default configuration of the module"
  default = []
  type = list(
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

locals {
  tagging_functionapp_log_signals_default = [
    {
      name         = "Tagging Function - Critical"
      query        = "TagData_CL"
      severity     = 0
      frequency    = 5
      time_window  = 10
      action_group = "tm-critical-actiongroup"

      trigger = {
        operator  = "LessThan"
        threshold = 1
      }
    }
  ]

  tagging_functionapp_log_signals = concat(local.tagging_functionapp_log_signals_default, var.tagging_functionapp_log_signals)
}
