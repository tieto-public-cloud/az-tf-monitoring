data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "function_rg" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "function_storage" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.function_rg.name
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
  table_name           = "Config"
  storage_account_name = azurerm_storage_account.function_storage.name

  partition_key = "Config"
  row_key       = "1"

  entity = {
    ResourceGroupName          = var.law_resource_group_name
    WorkspaceName              = var.law_name
    WorkingSubscriptionId      = data.azurerm_subscription.current.subscription_id
    TargetSubscriptionId       = var.target_subscription_id
    StorageAccountName         = azurerm_storage_account.function_storage.name
    StorageAccountResGroupName = data.azurerm_resource_group.function_rg.name
    Delta                      = var.tag_retrieval_interval
  }

  depends_on = [
    azurerm_storage_table.config
  ]
}

# resource "azurerm_application_insights" "function_insights" {
#   name                = var.name
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.function_rg.name
#   application_type    = "web"
# }

resource "azurerm_app_service_plan" "function_plan" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = data.azurerm_resource_group.function_rg.name
  kind                         = "FunctionApp"
  maximum_elastic_worker_count = 1

  sku {
    tier     = "Dynamic"
    size     = "Y1"
    capacity = 0
  }

  tags = var.common_tags
}

resource "azurerm_function_app" "function_app" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.function_rg.name
  app_service_plan_id        = azurerm_app_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION = "~7"
    # APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.function_insights.instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  source_control {
    repo_url           = var.source_repository
    branch             = var.source_repository_branch
    manual_integration = true
  }

  tags = var.common_tags
}

resource "azurerm_role_assignment" "function_role_contributor_law" {
  count = var.assign_roles ? 1 : 0

  scope                = var.law_id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_role_contributor_self_storage" {
  count = var.assign_roles ? 1 : 0

  scope                = azurerm_storage_account.function_storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_role_reader_target_sub" {
  count                = var.assign_roles ? 1 : 0

  scope                = "/subscriptions/${var.target_subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "function_app_diag" {
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_function_app.function_app.id
  log_analytics_workspace_id = var.law_id

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
