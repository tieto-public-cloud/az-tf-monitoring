resource "azurerm_storage_account" "function_storage" {
  count                    = var.use_resource_tags == true ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.common_tags
}

resource "azurerm_storage_table" "config" {
  count                = var.use_resource_tags == true ? 1 : 0
  name                 = "Config"
  storage_account_name = azurerm_storage_account.function_storage[0].name
}

resource "azurerm_storage_table" "temp" {
  count                = var.use_resource_tags == true ? 1 : 0
  name                 = "ResTags"
  storage_account_name = azurerm_storage_account.function_storage[0].name
}

resource "azurerm_storage_table_entity" "config_data" {
  count                = var.use_resource_tags == true ? 1 : 0
  depends_on           = [azurerm_storage_table.config]
  storage_account_name = azurerm_storage_account.function_storage[0].name
  table_name           = "Config"

  partition_key = "Config"
  row_key       = "1"

  entity = {
    ResourceGroupName = local.resource_group_name
    WorkspaceName     = var.log_analytics_workspace_name
    Delta             = "3600"
  }
}

resource "azurerm_application_insights" "monitor-tagging-insights" {
  count               = var.use_resource_tags == true ? 1 : 0
  name                = var.monitor_tagging_fapp_name
  location            = var.location
  resource_group_name = local.resource_group_name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "monitor-tagging" {
  count                        = var.use_resource_tags == true ? 1 : 0
  name                         = var.monitor_tagging_fapp_name
  location                     = var.location
  resource_group_name          = local.resource_group_name
  kind                         = "FunctionApp"
  maximum_elastic_worker_count = 1
  sku {
    tier     = "Dynamic"
    size     = "Y1"
    capacity = 0
  }
  tags = var.common_tags
}

resource "azurerm_function_app" "monitor-tagging" {
  count                      = var.use_resource_tags == true ? 1 : 0
  name                       = var.monitor_tagging_fapp_name
  location                   = var.location
  resource_group_name        = local.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.monitor-tagging[0].id
  storage_account_name       = azurerm_storage_account.function_storage[0].name
  storage_account_access_key = azurerm_storage_account.function_storage[0].primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION = "~7"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.monitor-tagging-insights[0].instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  source_control {
    repo_url           = var.monitor_tagging_function_repo
    branch             = "main"
    manual_integration = true
  }
  tags = var.common_tags
}

resource "azurerm_role_assignment" "function-owner" {
  count                = var.use_resource_tags == true ? 1 : 0
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${local.resource_group_name}"
  role_definition_name = "Owner"
  principal_id         = azurerm_function_app.monitor-tagging[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "function-reader" {
  count                = var.use_resource_tags == true ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.monitor-tagging[0].identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "monitor-tagging-diag" {
  count                      = var.use_resource_tags == true ? 1 : 0
  name                       = "${var.monitor_tagging_fapp_name}-diag"
  target_resource_id         = azurerm_function_app.monitor-tagging[0].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace[0].id

  log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

module "monitor-tagging" {
  source                     = "../alerts"
  query_alerts               = var.tagging_query
  deploy_monitoring          = var.use_resource_tags
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

