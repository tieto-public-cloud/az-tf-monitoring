variable "ag_default_webhook_service_uri" {
  description = "Webhook URI for sending events, including any secrets necessary for authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.ag_default_webhook_service_uri) > 0
    error_message = "Allowed value for ag_default_webhook_service_uri is a non-empty string."
  }
}

variable "ag_default_use_common_alert_schema" {
  description = "Send default alerts in the Azure Common Alert schema"
  type        = bool
  default     = true
}

variable "action_groups" {
  description = "Additional Action Groups to exetend the default configuration of the module"
  default     = []
  type        = list(
    object({
      name       = string
      short_name = string

      email = optional(object({
        name                    = string
        email_address           = string
        use_common_alert_schema = optional(bool)
      }))

      webhook = optional(object({
        name                    = string
        service_uri             = string
        use_common_alert_schema = optional(bool)
      }))

      arm_role_receiver = optional(object({
        name                    = string
        role_id                 = string
        use_common_alert_schema = optional(bool)
      }))

      # automation_runbook_receiver = optional(object({
      #   name                    = string
      #   automation_account_id   = string
      #   runbook_name            = string
      #   webhook_resource_id     = string
      #   is_global_runbook       = string
      #   service_uri             = string
      #   use_common_alert_schema = optional(bool)
      # }))

      # azure_app_push_receiver = optional(object({
      #   name          = string
      #   email_address = string
      # }))

      # azure_function_receiver = optional(object({
      #   name                     = string
      #   function_app_resource_id = string
      #   function_name            = string
      #   http_trigger_url         = string
      #   use_common_alert_schema  = optional(bool)
      # }))

      # itsm_receiver = optional(object({
      #   name                 = string
      #   workspace_id         = string
      #   connection_id        = string
      #   ticket_configuration = string
      #   region               = string
      # }))

      # logic_app_receiver = optional(object({
      #   name                    = string
      #   resource_id             = string
      #   callback_url            = string
      #   use_common_alert_schema = optional(bool)
      # }))

      # sms_receiver = optional(object({
      #   name         = string
      #   country_code = string
      #   phone_number = string
      # }))
    })
  )
}

# Combine defaults with any custom AGs provided by the caller.
# Use a real URI in defaults, take it from a variable provided by the caller.
locals {
  action_groups_default = [
    {
      name       = "tm-critical-actiongroup"
      short_name = "tm-crit-ag"
      webhook = {
        name                    = "Webhook"
        service_uri             = nonsensitive(var.ag_default_webhook_service_uri)
        use_common_alert_schema = var.ag_default_use_common_alert_schema
      }
    },
    {
      name       = "tm-warning-actiongroup"
      short_name = "tm-warn-ag"
      webhook = {
        name                    = "Webhook"
        service_uri             = nonsensitive(var.ag_default_webhook_service_uri)
        use_common_alert_schema = var.ag_default_use_common_alert_schema
      }
    }
  ]
  action_groups = concat(local.action_groups_default, var.action_groups)
}
