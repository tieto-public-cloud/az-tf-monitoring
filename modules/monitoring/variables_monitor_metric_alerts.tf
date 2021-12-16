variable "deploy_custom_metric_alerts" {
  description = "Whether to deploy Monitoring custom metric alerts"
  type        = bool
  default     = false
}

variable "custom_metric_alerts" {
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
      scope                    = string
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
