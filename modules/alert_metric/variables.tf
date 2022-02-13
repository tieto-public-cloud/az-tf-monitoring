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

variable "metric_alerts" {
  description = "List of metric based alerts to deploy"
  default     = []
  type = list(
    object({
      name                     = string
      enabled                  = optional(bool)
      auto_mitigate            = optional(bool)
      description              = optional(string)
      frequency                = optional(string)
      severity                 = optional(number)
      target_resource_type     = optional(string)
      target_resource_location = optional(string)
      window_size              = optional(string)
      action_group             = string
      scopes                   = list(string)

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
}
