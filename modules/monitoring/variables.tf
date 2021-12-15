variable "log_analytics_workspace_resource_group" {
  type        = string
  description = "The log Analytics Workspace resource group name"
  default     = ""
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

# variable "use_resource_tags" {
#   description = "Whether to deploy function app that enables usage of resource tags in monitoring solution"
#   type        = bool
#   default     = false
# }

variable "storage_account_name" {
  description = "Name of storage account for Resource tagging function"
  type        = string
  default     = null
}


variable "monitor_tagging_fapp_rg" {
  description = "Resource group name with Resource tagging function"
  type        = string
  default     = null
}


variable "monitor_tagging_fapp_name" {
  description = "Name of Resource tagging function"
  type        = string
  default     = null
}

variable "monitor_tagging_function_repo" {
  description = "Source code repository URL for monitor tagging Azure Function"
  type        = string
  default     = "https://github.com/tieto-public-cloud/az-func-monitoring-tagging.git"
}

variable "common_tags" {
  type        = map(any)
  description = "Map of Default Tags"
}
