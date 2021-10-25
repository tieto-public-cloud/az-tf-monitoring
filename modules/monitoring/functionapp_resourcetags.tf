resource "azurerm_resource_group" "function_rg" {
  #  count                    = var.use_resource_tags == true ? 1 : 0
  name     = var.monitor_tagging_fapp_rg
  location = var.location

  tags = var.common_tags
}

resource "azurerm_storage_account" "function_storage" {
  #  count                    = var.use_resource_tags == true ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = var.monitor_tagging_fapp_rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.common_tags
}

resource "azurerm_storage_table" "config" {
  # count                = var.use_resource_tags == true ? 1 : 0
  name = "Config"
  #  storage_account_name = azurerm_storage_account.function_storage[0].name
  storage_account_name = azurerm_storage_account.function_storage.name
}

resource "azurerm_storage_table" "temp" {
  #  count                = var.use_resource_tags == true ? 1 : 0
  name = "ResTags"
  #  storage_account_name = azurerm_storage_account.function_storage[0].name
  storage_account_name = azurerm_storage_account.function_storage.name
}

resource "azurerm_storage_table_entity" "config_data" {
  #  count                = var.use_resource_tags == true ? 1 : 0
  depends_on = [azurerm_storage_table.config]
  #  storage_account_name = azurerm_storage_account.function_storage[0].name
  storage_account_name = azurerm_storage_account.function_storage.name
  table_name           = "Config"

  partition_key = "Config"
  row_key       = "1"

  entity = {
    ResourceGroupName          = var.log_analytics_workspace_resource_group
    WorkspaceName              = var.log_analytics_workspace_name
    StorageAccountName         = var.storage_account_name
    StorageAccountResGroupName = var.monitor_tagging_fapp_rg
    Delta                      = "3600"
  }
}

resource "azurerm_application_insights" "monitor-tagging-insights" {
  #  count               = var.use_resource_tags == true ? 1 : 0
  name                = var.monitor_tagging_fapp_name
  location            = var.location
  resource_group_name = var.monitor_tagging_fapp_rg
  application_type    = "web"
}

resource "azurerm_app_service_plan" "monitor-tagging" {
  # count                        = var.use_resource_tags == true ? 1 : 0
  name                         = var.monitor_tagging_fapp_name
  location                     = var.location
  resource_group_name          = var.monitor_tagging_fapp_rg
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
  #  count                      = var.use_resource_tags == true ? 1 : 0
  name                = var.monitor_tagging_fapp_name
  location            = var.location
  resource_group_name = var.monitor_tagging_fapp_rg
  # app_service_plan_id        = azurerm_app_service_plan.monitor-tagging[0].id
  # storage_account_name       = azurerm_storage_account.function_storage[0].name
  # storage_account_access_key = azurerm_storage_account.function_storage[0].primary_access_key
  app_service_plan_id        = azurerm_app_service_plan.monitor-tagging.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION = "~7"
    #  APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.monitor-tagging-insights[0].instrumentation_key
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.monitor-tagging-insights.instrumentation_key
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

resource "azurerm_role_assignment" "function-owner-law-rg" {
  #  count                = var.use_resource_tags == true ? 1 : 0
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.log_analytics_workspace_resource_group}"
  role_definition_name = "Owner"
  # principal_id         = azurerm_function_app.monitor-tagging[0].identity[0].principal_id
  principal_id = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

resource "azurerm_role_assignment" "function-owner-own-rg" {
  #  count                = var.use_resource_tags == true ? 1 : 0
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.monitor_tagging_fapp_rg}"
  role_definition_name = "Owner"
  # principal_id         = azurerm_function_app.monitor-tagging[0].identity[0].principal_id
  principal_id = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

resource "azurerm_role_assignment" "function-reader" {
  #  count                = var.use_resource_tags == true ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  # principal_id         = azurerm_function_app.monitor-tagging[0].identity[0].principal_id
  principal_id = azurerm_function_app.monitor-tagging.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "monitor-tagging-diag" {
  #  count                      = var.use_resource_tags == true ? 1 : 0
  name = "${var.monitor_tagging_fapp_name}-diag"
  # target_resource_id         = azurerm_function_app.monitor-tagging[0].id
  target_resource_id         = azurerm_function_app.monitor-tagging.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id


  log {
    category = "FunctionAppLogs"
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

module "monitor-tagging" {
  source                     = "../alerts"
  query_alerts               = var.tagging_query
  deploy_monitoring          = true
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

