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


variable "common_tags" {
  type        = map(any)
  description = "Map of Default Tags"
}
