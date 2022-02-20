variable "location" {
  description = "The location (region) for deployment of all monitoring resources"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Allowed value for location is a non-empty string."
  }
}

variable "snow_webhook_url" {
  description = "Webhook URL for sending events to ServiceNow"
  type        = string

  validation {
    condition     = length(var.snow_webhook_url) > 0
    error_message = "Allowed value for snow_webhook_url is a non-empty string."
  }
}

variable "snow_webhook_username" {
  description = "Webhook URL for sending events"
  type        = string

  validation {
    condition     = length(var.snow_webhook_username) > 0
    error_message = "Allowed value for snow_webhook_username is a non-empty string."
  }
}

variable "snow_webhook_password" {
  description = "Webhook URL for sending events"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.snow_webhook_password) > 0
    error_message = "Allowed value for snow_webhook_password is a non-empty string."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to use for the ServiceNow Logic App, must exist"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Allowed value for resource_group_name is a non-empty string."
  }
}

variable "name" {
  description = "Name of the Azure Logic App to be created for converting alert data from Common Alert schema to ServiceNow schema"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Allowed value for name is a non-empty string."
  }
}

variable "law_id" {
  type        = string
  description = "The Log Analytics Workspace ID to use as a source for getting alert context"

  validation {
    condition     = length(var.law_id) > 0
    error_message = "Allowed value for law_id is a non-empty string."
  }
}

variable "assign_roles" {
  description = "Assign required Logic App roles, account used for deployment must have permissions to assign IAM roles"
  type        = bool
  default     = true
}

variable "common_tags" {
  type        = map(any)
  default     = {}
  description = "Map of default tags assigned to all deployed resources"
}
