variable "law_resource_group_name" {
  type        = string
  description = "The Log Analytics Workspace resource group name"

  validation {
    condition     = length(var.law_resource_group_name) > 0
    error_message = "Allowed value for law_resource_group_name is a non-empty string"
  }
}

variable "law_name" {
  type        = string
  description = "The Log Analytics Workspace name"

  validation {
    condition     = length(var.law_name) > 0
    error_message = "Allowed value for law_name is a non-empty string"
  }
}

variable "location" {
  type        = string
  description = "The location (region) for deployment of all monitoring resources"

  validation {
    condition     = length(var.location) > 0
    error_message = "Allowed value for location is a non-empty string"
  }
}

variable "common_tags" {
  type        = map(any)
  default     = {}
  description = "Map of default tags assigned to all deployed resources"
}

variable "submodule_source" {
  type        = string
  default     = "remote"
  description = "Internal variable used for development and testing, do not use!"

  validation {
    condition     = contains(["remote", "local"], var.submodule_source)
    error_message = "Allowed values for submodule_source are \"remote\" or \"local\""
  }
}

variable "submodule_version" {
  type        = string
  default     = "v2.0"
  description = "Internal variable used during development, do not use!"

  validation {
    condition     = length(var.submodule_version) > 0
    error_message = "Allowed value for submodule_version is a non-empty string"
  }
}
