data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "snow_logic_app_rg" {
  name = var.resource_group_name
}

data "local_file" "snow_logic_app_schema" {
  filename = "${path.module}/files/logicapp_workflow_schema.json"
}

resource "azurerm_logic_app_workflow" "snow_logic_app" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.snow_logic_app_rg.name

  identity {
    type = "SystemAssigned"
  }

  parameters = {
    "Query Column Mapping"        = jsonencode({
      CMDBId         = 1
      SubscriptionId = 0
    })
    "ServiceNow Webhook Password" = var.snow_webhook_password
    "ServiceNow Webhook URL"      = var.snow_webhook_url
    "ServiceNow Webhook Username" = var.snow_webhook_username
    "Severity Mapping"            = jsonencode({
      Sev0 = 1
      Sev1 = 2
      Sev2 = 3
      Sev3 = 4
      Sev4 = 4
    })
  }

  workflow_parameters = {
    for kparam, vparam in jsondecode(data.local_file.snow_logic_app_schema.content).definition.parameters : kparam => jsonencode(vparam)
  }
  workflow_schema     = jsondecode(data.local_file.snow_logic_app_schema.content).definition["$schema"]
  workflow_version    = jsondecode(data.local_file.snow_logic_app_schema.content).definition.contentVersion

  tags = var.common_tags
}

resource "azurerm_logic_app_trigger_http_request" "snow_logic_app_http_trigger" {
  name         = "manual"
  logic_app_id = azurerm_logic_app_workflow.snow_logic_app.id

  method = "POST"
  schema = jsonencode(jsondecode(data.local_file.snow_logic_app_schema.content).definition.triggers.manual)
}

resource "azurerm_logic_app_action_custom" "snow_logic_app_kickoff_action" {
  name         = "Signal_Type"
  logic_app_id = azurerm_logic_app_workflow.snow_logic_app.id

  body = jsonencode(jsondecode(data.local_file.snow_logic_app_schema.content).definition.actions["Signal_Type"])
}

resource "azurerm_role_assignment" "snow_logic_app_role_reader_law" {
  count = var.assign_roles ? 1 : 0

  scope                = var.law_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_logic_app_workflow.snow_logic_app.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "snow_logic_app_diag" {
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_logic_app_workflow.snow_logic_app.id
  log_analytics_workspace_id = var.law_id

  log {
    category = "WorkflowRuntime"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
