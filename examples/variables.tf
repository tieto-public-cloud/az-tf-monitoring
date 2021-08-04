
locals {
  query_alert  = merge(var.query_alert_local, var.query_alert_default)
  metric_alert = merge(var.metric_alert_local, var.metric_alert_default)
}

variable "query_alert_local" {
  description = "Locally present alerts"
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
  default = null
}

variable "query_alert_default" {
  description = "Default alerts"
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
  default = null
}

variable "metric_alert_local" {
  description = "Locally present alerts"
  type = map(
    object({
      enabled                  = optional(bool)
      auto_mitigate            = optional(bool)
      description              = optional(string)
      frequency                = optional(string)
      severity                 = optional(number)
      target_resource_type     = optional(string)
      target_resource_location = optional(string)
      window_size              = optional(string)
      action_group             = string
      criteria = optional(object({
        metric_namespace = string
        metric_name      = string
        aggregation      = string
        operator         = string
        threshold        = number
        dimension = optional(object({
          name     = string
          operator = string
          values   = list(string)
        }))
        skip_metric_validation = optional(bool)
      }))
      dynamic_criteria = optional(object({
        metric_namespace  = string
        metric_name       = string
        aggregation       = string
        operator          = string
        alert_sensitivity = string
        dimension = optional(object({
          name     = string
          operator = string
          values   = list(string)
        }))
        evaluation_total_count   = optional(number)
        evaluation_failure_count = optional(number)
        ignore_data_before       = optional(string)
        skip_metric_validation   = optional(bool)
      }))
      application_insights_web_test_location_availability_criteria = optional(object({
        web_test_id           = string
        component_id          = string
        failed_location_count = number
      }))
    })
  )
  default = null
}

variable "metric_alert_default" {
  description = "Default alerts"
  type = map(
    object({
      enabled                  = optional(bool)
      auto_mitigate            = optional(bool)
      description              = optional(string)
      frequency                = optional(string)
      severity                 = optional(number)
      target_resource_type     = optional(string)
      target_resource_location = optional(string)
      window_size              = optional(string)
      action_group             = string
      criteria = optional(object({
        metric_namespace = string
        metric_name      = string
        aggregation      = string
        operator         = string
        threshold        = number
        dimension = optional(object({
          name     = string
          operator = string
          values   = list(string)
        }))
        skip_metric_validation = optional(bool)
      }))
      dynamic_criteria = optional(object({
        metric_namespace  = string
        metric_name       = string
        aggregation       = string
        operator          = string
        alert_sensitivity = string
        dimension = optional(object({
          name     = string
          operator = string
          values   = list(string)
        }))
        evaluation_total_count   = optional(number)
        evaluation_failure_count = optional(number)
        ignore_data_before       = optional(string)
        skip_metric_validation   = optional(bool)
      }))
      application_insights_web_test_location_availability_criteria = optional(object({
        web_test_id           = string
        component_id          = string
        failed_location_count = number
      }))
    })
  )
  default = null
}

