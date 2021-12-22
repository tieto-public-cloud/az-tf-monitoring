#
# Azure Monitor action group configurations
#

variable "tagging_query" {
  description = "Tagging Function config for query based monitoring"
  default = {
    "Tagging-Function-Critical" = {
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
