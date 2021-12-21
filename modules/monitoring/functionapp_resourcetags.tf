resource "azurerm_resource_group" "function_rg" {
  name     = var.monitor_tagging_fapp_rg
  location = var.location

  tags = var.common_tags
}

resource "azurerm_storage_account" "function_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.function_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.common_tags
}

resource "azurerm_storage_table" "config" {
  name                 = "Config"
  storage_account_name = azurerm_storage_account.function_storage.name
}

resource "azurerm_storage_table" "temp" {
  name                 = "ResTags"
  storage_account_name = azurerm_storage_account.function_storage.name
}

resource "azurerm_storage_table_entity" "config_data" {
  depends_on           = [azurerm_storage_table.config]
  storage_account_name = azurerm_storage_account.function_storage.name
  table_name           = "Config"

  partition_key = "Config"
  row_key       = "1"

  entity = {
    ResourceGroupName          = var.log_analytics_workspace_resource_group
    WorkspaceName              = var.log_analytics_workspace_name
    StorageAccountName         = azurerm_storage_account.function_storage.name
    StorageAccountResGroupName = azurerm_resource_group.function_rg.name
    Delta                      = "3600"
  }
}

# resource "azurerm_application_insights" "monitor-tagging-insights" {
#   name                = var.monitor_tagging_fapp_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.function_rg.name
#   application_type    = "web"
# }

resource "azurerm_app_service_plan" "monitor-tagging" {
  name                         = var.monitor_tagging_fapp_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.function_rg.name
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
  name                       = var.monitor_tagging_fapp_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.function_rg.name
  app_service_plan_id        = azurerm_app_service_plan.monitor-tagging.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION = "~7"
    # APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.monitor-tagging-insights.instrumentation_key
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

resource "azurerm_role_assignment" "function-contributor-law-rg" {
  count = var.assign_functionapp_perms == true ? 1 : 0
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.log_analytics_workspace_resource_group}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

resource "azurerm_role_assignment" "function-contributor-self-rg" {
  count = var.assign_functionapp_perms == true ? 1 : 0
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.function_rg.name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

resource "azurerm_role_assignment" "function-reader" {
  count = var.assign_functionapp_perms == true ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

# resource "azurerm_monitor_diagnostic_setting" "monitor-tagging-diag" {
#   name = "${var.monitor_tagging_fapp_name}-diag"
#   target_resource_id         = azurerm_function_app.monitor-tagging.id
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id


#   log {
#     category = "FunctionAppLogs"
#     enabled  = true
#     retention_policy {
#       days    = 0
#       enabled = false
#     }
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#     retention_policy {
#       days    = 0
#       enabled = false
#     }
#   }
# }

module "monitor-tagging" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = var.tagging_query
  deploy_monitoring          = true
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

