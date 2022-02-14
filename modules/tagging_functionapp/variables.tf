variable "location" {
  description = "The location (region) for deployment of all monitoring resources"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Allowed value for location is a non-empty string."
  }
}

variable "law_id" {
  type        = string
  description = "The Log Analytics Workspace ID to use as a target for sent resource tag data"

  validation {
    condition     = length(var.law_id) > 0
    error_message = "Allowed value for law_id is a non-empty string."
  }
}

variable "law_resource_group_name" {
  description = "The Log Analytics Workspace resource group name, must exist"
  type        = string

  validation {
    condition     = length(var.law_resource_group_name) > 0
    error_message = "Allowed value for law_resource_group_name is a non-empty string."
  }
}

variable "law_name" {
  type        = string
  description = "The Log Analytics Workspace name to use as a target for sent resource tag data, must exist"

  validation {
    condition     = length(var.law_name) > 0
    error_message = "Allowed value for law_name is a non-empty string."
  }
}

variable "target_subscription_id" {
  description = "ID of the subscription from which to read resource tag data"
  type        = string

  validation {
    condition     = length(var.target_subscription_id) > 0
    error_message = "Allowed value for target_subscription_id is a non-empty string."
  }
}

variable "storage_account_name" {
  description = "Name of the storage account to be created for the tagging function"
  type        = string

  validation {
    condition     = length(var.storage_account_name) > 0
    error_message = "Allowed value for storage_account_name is a non-empty string."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to use for the tagging function, must exist"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Allowed value for resource_group_name is a non-empty string."
  }
}

variable "name" {
  description = "Name of the Azure Function app to be created for pushing resource tag data into LAW"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Allowed value for name is a non-empty string."
  }
}

variable "tag_retrieval_interval" {
  description = "How often tag values should be refreshed from the target subscription, in seconds"
  type        = number
  default     = 3600

  validation {
    condition     = var.tag_retrieval_interval > 90
    error_message = "Allowed value for tag_retrieval_interval is a number larger than 90."
  }
}

variable "source_repository" {
  description = "Source code repository URL for monitor tagging Azure Function"
  type        = string
  default     = "https://github.com/tieto-public-cloud/az-func-monitoring-tagging"

  validation {
    condition     = length(var.source_repository) > 0
    error_message = "Allowed value for source_repository is a non-empty string."
  }
}

variable "source_repository_branch" {
  description = "A branch of the code to check out from the repository, commonly main or master"
  type        = string
  default     = "main"

  validation {
    condition     = length(var.source_repository_branch) > 0
    error_message = "Allowed value for source_repository_branch is a non-empty string."
  }
}

variable "assign_roles" {
  description = "Assign required Function App roles, account used for deployment must have permissions to assign IAM roles"
  type        = bool
  default     = true
}

variable "common_tags" {
  type        = map(any)
  default     = {}
  description = "Map of default tags assigned to all deployed resources"
}
