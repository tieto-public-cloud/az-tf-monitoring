variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_resource_group" {
  type        = string
  description = "The log Analytics Workspace resource group name"
  default     = ""
}

variable "create_log_analytics_workspace" {
  description = "Whether to create log analytics workspace and use it for all monitoring resources"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "The log Analytics Workspace Name"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your monitoring resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "use_resource_tags" {
  description = "Whether to deploy function app that enables usage of resource tags in monitoring solution"
  type        = bool
  default     = false
}

variable "storage_account_name" {
  description = "Name of storage account for Resource tagging function storage"
  type        = string
  default     = null
}

variable "monitor_tagging_fapp_name" {
  description = "Name of Resource tagging function storage"
  type        = string
  default     = null
}

variable "monitor_tagging_function_repo" {
  description = "Source code repository URL for monitor tagging Azure Function"
  type        = string
  default     = "https://github.com/junkett/azmontag.git"
}

variable "common_tags" {
  type        = map
  description = "Map of Default Tags"
}

# locals {
#   query_alert  = merge(var.query_alert_local, var.query_alert_default)
#   metric_alert = merge(var.metric_alert_local, var.metric_alert_default)
# }

# variable "query_alert_local" {
#   description = "Locally present alerts"
#   type = map(
#     object({
#       name         = string
#       enabled      = optional(bool)
#       query        = string
#       severity     = optional(number)
#       frequency    = number
#       time_window  = number
#       action_group = string
#       throttling   = optional(number)
#       trigger = object({
#         operator  = string
#         threshold = number
#         metric_trigger = optional(object({
#           operator  = string
#           threshold = string
#           type      = string
#           column    = string
#         }))
#       })
#     })
#   )
#   default = null
# }

# variable "query_alert_default" {
#   description = "Default alerts"
#   type = map(
#     object({
#       name         = string
#       enabled      = optional(bool)
#       query        = string
#       severity     = optional(number)
#       frequency    = number
#       time_window  = number
#       action_group = string
#       throttling   = optional(number)
#       trigger = object({
#         operator  = string
#         threshold = number
#         metric_trigger = optional(object({
#           operator  = string
#           threshold = string
#           type      = string
#           column    = string
#         }))
#       })
#     })
#   )
#   default = null
# }

# variable "metric_alert_local" {
#   description = "Locally present alerts"
#   type = map(
#     object({
#       enabled                  = optional(bool)
#       auto_mitigate            = optional(bool)
#       description              = optional(string)
#       frequency                = optional(string)
#       severity                 = optional(number)
#       target_resource_type     = optional(string)
#       target_resource_location = optional(string)
#       window_size              = optional(string)
#       action_group             = string
#       criteria = optional(object({
#         metric_namespace = string
#         metric_name      = string
#         aggregation      = string
#         operator         = string
#         threshold        = number
#         dimension = optional(object({
#           name     = string
#           operator = string
#           values   = list(string)
#         }))
#         skip_metric_validation = optional(bool)
#       }))
#       dynamic_criteria = optional(object({
#         metric_namespace  = string
#         metric_name       = string
#         aggregation       = string
#         operator          = string
#         alert_sensitivity = string
#         dimension = optional(object({
#           name     = string
#           operator = string
#           values   = list(string)
#         }))
#         evaluation_total_count   = optional(number)
#         evaluation_failure_count = optional(number)
#         ignore_data_before       = optional(string)
#         skip_metric_validation   = optional(bool)
#       }))
#       application_insights_web_test_location_availability_criteria = optional(object({
#         web_test_id           = string
#         component_id          = string
#         failed_location_count = number
#       }))
#     })
#   )
#   default = null
# }

# variable "metric_alert_default" {
#   description = "Default alerts"
#   type = map(
#     object({
#       enabled                  = optional(bool)
#       auto_mitigate            = optional(bool)
#       description              = optional(string)
#       frequency                = optional(string)
#       severity                 = optional(number)
#       target_resource_type     = optional(string)
#       target_resource_location = optional(string)
#       window_size              = optional(string)
#       action_group             = string
#       criteria = optional(object({
#         metric_namespace = string
#         metric_name      = string
#         aggregation      = string
#         operator         = string
#         threshold        = number
#         dimension = optional(object({
#           name     = string
#           operator = string
#           values   = list(string)
#         }))
#         skip_metric_validation = optional(bool)
#       }))
#       dynamic_criteria = optional(object({
#         metric_namespace  = string
#         metric_name       = string
#         aggregation       = string
#         operator          = string
#         alert_sensitivity = string
#         dimension = optional(object({
#           name     = string
#           operator = string
#           values   = list(string)
#         }))
#         evaluation_total_count   = optional(number)
#         evaluation_failure_count = optional(number)
#         ignore_data_before       = optional(string)
#         skip_metric_validation   = optional(bool)
#       }))
#       application_insights_web_test_location_availability_criteria = optional(object({
#         web_test_id           = string
#         component_id          = string
#         failed_location_count = number
#       }))
#     })
#   )
#   default = null
# }

