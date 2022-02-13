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

variable "mgmthub_subscription_id" {
  description = "ID of the Azure subscription hosting the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "monexec_subscription_id" {
  description = "ID of the Azure subscription hosting the supporting functions used for log data enrichment"
  type        = string
}

variable "montarget_subscription_ids" {
  description = "IDs of the Azure subscription that is to be monitored by this deployment"
  type        = list(string)
}

variable "mgmt_law_name" {
  description = "The name of the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "mgmt_law_resource_group" {
  description = "The Resource Group housing the Log Analytics Workspace used for log collection and analysis"
  type        = string
}

variable "snow_webhook_uri" {
  description = "Webhook URI for sending Azure Common Alert schema events to ServiceNow, including any secrets necessary for authentication"
  type        = string
  sensitive   = true
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
  default     = {
    environment = "dev"
    owner       = "jdoe"
  }
}
