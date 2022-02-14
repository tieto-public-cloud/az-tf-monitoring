variable "law_resource_group_name" {
  type        = string
  description = "The Log Analytics Workspace resource group name"

  validation {
    condition     = length(var.law_resource_group_name) > 0
    error_message = "Allowed value for law_resource_group_name is a non-empty string."
  }
}

variable "law_name" {
  type        = string
  description = "The Log Analytics Workspace name"

  validation {
    condition     = length(var.law_name) > 0
    error_message = "Allowed value for law_name is a non-empty string."
  }
}

variable "location" {
  type        = string
  description = "The location (region) for deployment of all monitoring resources"

  validation {
    condition     = length(var.location) > 0
    error_message = "Allowed value for location is a non-empty string."
  }
}

variable "monitor" {
  type        = list(string)
  description = "A list of resource types to monitor, everything is turned off by default"
  default     = []
}

variable "common_tags" {
  type        = map(any)
  default     = {}
  description = "Map of default tags assigned to all deployed resources"
}
