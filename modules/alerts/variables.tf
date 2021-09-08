variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "deploy_monitoring" {
  description = "Deploy Monitoring"
  type        = bool
}

variable "l" {
  description = "The location/region to keep all your monitoring resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
  default     = null
}

variable "location" {
  description = "The location/region to keep all your monitoring resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
variable "query_alerts" {
  description = "Query Alerts"
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

variable "ag" {
  description = "Action Groups"
}