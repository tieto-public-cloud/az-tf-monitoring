data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group
}

data "azurerm_subscription" "current" {}

module "monitor-azurevm" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.azurevm_query
  deploy_monitoring          = var.deploy_monitoring_azurevm
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-azuresql" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.azuresql_query
  deploy_monitoring          = var.deploy_monitoring_azuresql
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-logicapps" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.logicapps_query
  deploy_monitoring          = var.deploy_monitoring_logicapps
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-backups" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.backup_query
  deploy_monitoring          = var.deploy_monitoring_backup
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-agw" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.agw_query
  deploy_monitoring          = var.deploy_monitoring_agw
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-azurefunction" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.azurefunction_query
  deploy_monitoring          = var.deploy_monitoring_azurefunction
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-datafactory" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.datafactory_query
  deploy_monitoring          = var.deploy_monitoring_datafactory
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-expressroute" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.expressroute_query
  deploy_monitoring          = var.deploy_monitoring_expressroute
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-lb" {
  source                     = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"
  query_alerts               = local.lb_query
  deploy_monitoring          = var.deploy_monitoring_lb
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "custom_metric_alerts" {
  source              = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_metric?ref=v1.0"
  resource_group_name = var.log_analytics_workspace_resource_group
  deploy_monitoring   = var.deploy_custom_metric_alerts
  metric_alerts       = local.metric_alerts
  ag                  = azurerm_monitor_action_group.action_group
}