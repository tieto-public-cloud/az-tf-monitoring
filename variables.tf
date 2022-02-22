variable "azurerm_client_id" {
  description = "Client ID for authentication to Azure, see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret"
  type        = string
}

variable "azurerm_client_secret" {
  description = "Client secret for authentication to Azure, see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret"
  type        = string
}

variable "azurerm_tenant_id" {
  description = "Tenant ID for authenticaiton to Azure, see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret"
  type        = string
}

variable "law_subscription_id" {
  description = "ID of the Azure subscription hosting the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "aux_subscription_id" {
  description = "ID of the Azure subscription hosting the supporting functions used for log data enrichment"
  type        = string
}

variable "target_subscription_ids" {
  description = "IDs of the Azure subscription that are to be monitored by this deployment"
  type        = list(string)
}

variable "law_name" {
  description = "The name of the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "law_resource_group_name" {
  description = "The Resource Group housing the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "la_resource_group_name" {
  type        = string
  description = "The name of the Azure Logic App resource group to be created"

  validation {
    condition     = length(var.la_resource_group_name) > 0
    error_message = "Allowed value for la_resource_group_name is a non-empty string."
  }
}

variable "snow_la_name" {
  type        = string
  description = "The name of the Azure Logic App to be created"

  validation {
    condition     = length(var.snow_la_name) > 0
    error_message = "Allowed value for snow_la_name is a non-empty string."
  }
}

variable "tagging_la_name" {
  type        = string
  description = "The name of the Azure Logic App to be created"

  validation {
    condition     = length(var.tagging_la_name) > 0
    error_message = "Allowed value for tagging_la_name is a non-empty string."
  }
}

variable "snow_webhook_url" {
  description = "Webhook URL for sending Azure Common Alert schema events to ServiceNow"
  type        = string
}

variable "snow_webhook_username" {
  description = "Webhook username for sending Azure Common Alert schema events to ServiceNow"
  type        = string
}

variable "snow_webhook_password" {
  description = "Webhook password for sending Azure Common Alert schema events to ServiceNow, for basic auth"
  type        = string
  sensitive   = true
}

variable "sb_resource_group_name" {
  type        = string
  description = "The name of the Sandbox resource group to be created"

  validation {
    condition     = length(var.sb_resource_group_name) > 0
    error_message = "Allowed value for sb_resource_group_name is a non-empty string."
  }
}

variable "location" {
  description = "The Azure location of your subscriptions (region)"
  type        = string
  default     = "westeurope"
}

variable "monitored_tags" {
  description = "A set of tags marking a resource as in-scope for monitoring, only resources with these tags will be monitored"
  type        = map(any)
  default     = { te-managed-service = "workload" }
}

variable "common_tags" {
  description = "A set of tags added to all deployed resources, marking ownership and purpose"
  type        = map(any)
  default     = {}
}
