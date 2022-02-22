locals {
  law_connection_type = "azureloganalyticsdatacollector" # this needs to match workflow schema expectations, see json
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "tagging_logic_app_rg" {
  name = var.resource_group_name
}

data "local_file" "tagging_logic_app_schema" {
  filename = "${path.module}/files/logicapp_workflow_schema.json"
}

data "local_file" "law_api_connection_arm" {
  filename = "${path.module}/files/law_api_connection_arm.json"
}

resource "azurerm_resource_group_template_deployment" "lawdc" {
  name                = "${var.name}-${local.law_connection_type}-dpl"
  resource_group_name = data.azurerm_resource_group.tagging_logic_app_rg.name
  template_content    = data.local_file.law_api_connection_arm.content

  parameters_content = jsonencode({
    connectionName  = { value = local.law_connection_type }
    connectionType  = { value = local.law_connection_type }
    parameterValues = { value = {
      username    = var.law_workspace_id
      password    = var.law_primary_key
    }}
  })
  deployment_mode    = "Incremental"
}

resource "azurerm_logic_app_workflow" "tagging_logic_app" {
  name                       = var.name
  location                   = data.azurerm_resource_group.tagging_logic_app_rg.location
  resource_group_name        = data.azurerm_resource_group.tagging_logic_app_rg.name

  identity {
    type = "SystemAssigned"
  }

  parameters = {
    "$connections" = jsonencode({
      "${local.law_connection_type}" = {
        connectionId   = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.tagging_logic_app_rg.name}/providers/Microsoft.Web/connections/${local.law_connection_type}"
        connectionName = local.law_connection_type
        id             = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Web/locations/${data.azurerm_resource_group.tagging_logic_app_rg.location}/managedApis/${local.law_connection_type}"
      }
    })
    "Target Subscription IDs" = jsonencode(var.target_subscription_ids)
  }

  workflow_parameters = {
    for kparam, vparam in jsondecode(data.local_file.tagging_logic_app_schema.content).definition.parameters : kparam => jsonencode(vparam)
  }
  workflow_schema     = jsondecode(data.local_file.tagging_logic_app_schema.content).definition["$schema"]
  workflow_version    = jsondecode(data.local_file.tagging_logic_app_schema.content).definition.contentVersion

  tags = var.common_tags

  depends_on = [
    azurerm_resource_group_template_deployment.lawdc
  ]
}

resource "azurerm_logic_app_trigger_recurrence" "tagging_logic_app_trigger" {
  name         = "Periodically"
  logic_app_id = azurerm_logic_app_workflow.tagging_logic_app.id
  frequency    = "Hour"
  interval     = var.tag_retrieval_interval
}

resource "azurerm_logic_app_action_custom" "tagging_logic_app_kickoff_action" {
  name         = "For_Each_Target_Subscription"
  logic_app_id = azurerm_logic_app_workflow.tagging_logic_app.id

  body = jsonencode(jsondecode(data.local_file.tagging_logic_app_schema.content).definition.actions["For_Each_Target_Subscription"])
}

resource "azurerm_role_assignment" "tagging_logic_app_role_reader_sub" {
  count = var.assign_roles ? length(var.target_subscription_ids) : 0

  scope                = "/subscriptions/${var.target_subscription_ids[count.index]}"
  role_definition_name = "Reader"
  principal_id         = azurerm_logic_app_workflow.tagging_logic_app.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "tagging_logic_app_diag" {
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_logic_app_workflow.tagging_logic_app.id
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
