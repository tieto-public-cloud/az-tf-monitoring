variable "fa_resource_group_name" {
  type        = string
  description = "The name of the Azure Function app resource group to be created"

  validation {
    condition     = length(var.fa_resource_group_name) > 0
    error_message = "Allowed value for fa_resource_group_name is a non-empty string."
  }
}

variable "fa_name" {
  type        = string
  description = "The name of the Azure Function app to be created"

  validation {
    condition     = length(var.fa_name) > 0
    error_message = "Allowed value for fa_name is a non-empty string."
  }
}

variable "target_subscription_ids" {
  description = "IDs of the Azure subscription that are to be monitored by this deployment"
  type        = list(string)

  validation {
    condition     = length(var.target_subscription_ids) > 0
    error_message = "Allowed value for target_subscription_ids is a non-empty list."
  }
}

variable "fa_tag_retrieval_interval" {
  description = "How often tag values should be refreshed from the target subscription, in seconds"
  type        = number
  default     = 3600

  validation {
    condition     = var.fa_tag_retrieval_interval > 90
    error_message = "Allowed value for fa_tag_retrieval_interval is a number larger than 90."
  }
}

variable "assign_roles" {
  description = "Assign required Function App roles, account used for deployment must have permissions to assign IAM roles"
  type        = bool
  default     = true
}
