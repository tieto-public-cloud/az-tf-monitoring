variable "location" {
  description = "The location (region) for deployment of all monitoring resources"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Allowed value for location is a non-empty string."
  }
}

variable "law_id" {
  type        = string
  description = "The Log Analytics Workspace ID to use as a data source for deployed alerts"

  validation {
    condition     = length(var.law_id) > 0
    error_message = "Allowed value for law_id is a non-empty string."
  }
}

variable "law_resource_group_name" {
  description = "The Log Analytics Workspace resource group name, this RG will contain deployed alerts"
  type        = string

  validation {
    condition     = length(var.law_resource_group_name) > 0
    error_message = "Allowed value for law_resource_group_name is a non-empty string."
  }
}

variable "action_groups" {
  description = "List of available action groups to reference when deploying alerts"
  type        = list(any)

  validation {
    condition     = length(var.action_groups) > 0
    error_message = "Allowed value for action_groups is a non-empty list of objects."
  }
}

variable "deploy" {
  description = "Flag for controlling alert deployment regardless of provided list of alerts"
  type        = bool
  default     = true
}

variable "query_alerts" {
  description = "List of log query based alerts to deploy"
  default     = []
  type        = list(
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
