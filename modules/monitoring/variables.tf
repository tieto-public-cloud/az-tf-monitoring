variable "law_resource_group" {
  type        = string
  description = "The Log Analytics Workspace resource group name"
}

variable "law_name" {
  type        = string
  description = "The Log Analytics Workspace name"
}

variable "location" {
  type        = string
  description = "The location (region) for deployment of all monitoring resources"
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
