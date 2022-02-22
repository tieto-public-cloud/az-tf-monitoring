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
  description = "The Log Analytics Workspace ID to use for ops-related Logic App logs, Azure resource ID"

  validation {
    condition     = length(var.law_id) > 0
    error_message = "Allowed value for law_id is a non-empty string."
  }
}

variable "law_workspace_id" {
  description = "The Log Analytics workspace ID for remote logging; the ID used for agents, not Azure resource ID"
  type        = string

  validation {
    condition     = length(var.law_workspace_id) > 0
    error_message = "Allowed value for law_workspace_id is a non-empty string."
  }
}

variable "law_primary_key" {
  type        = string
  description = "The Log Analytics Workspace primary key to use for writing data"
  sensitive   = true

  validation {
    condition     = length(var.law_primary_key) > 0
    error_message = "Allowed value for law_primary_key is a non-empty string."
  }
}

variable "target_subscription_ids" {
  description = "List of IDs of the subscriptions from which to read resource tag data"
  type        = list(string)

  validation {
    condition     = length(var.target_subscription_ids) > 0
    error_message = "Allowed value for target_subscription_ids is a non-empty list."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to use for the Logic App, must exist"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Allowed value for resource_group_name is a non-empty string."
  }
}

variable "name" {
  description = "Name of the Azure Logic App to be created for pushing resource tag data into LAW"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Allowed value for name is a non-empty string."
  }
}

variable "tag_retrieval_interval" {
  description = "How often should tag values be refreshed from the target subscription(s), in hours"
  type        = number
  default     = 3

  validation {
    condition     = var.tag_retrieval_interval >= 1 && var.tag_retrieval_interval <= 24
    error_message = "Allowed value for tag_retrieval_interval is a number between 1 and 24."
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
