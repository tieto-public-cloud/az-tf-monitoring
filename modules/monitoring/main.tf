
# Local configuration - Default (required).

locals {
  log_analytics_workspace_name = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.name, azurerm_log_analytics_workspace.law.*.name, [""]), 0)
  resource_group_name          = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id   = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
}

# Datasources for Azure environment
# AzureRM provider client
data "azurerm_client_config" "current" {}

# Current Azure Subscription
data "azurerm_subscription" "current" {}

# All Azure Subscriptions
data "azurerm_subscriptions" "available" {}

# Resource Group Creation or selection - Default is "false"
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.log_analytics_workspace_resource_group
}

# Log Analytics Workspace Creation or selection - Default is "false"
data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  count               = var.create_log_analytics_workspace == false ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.log_analytics_workspace_resource_group
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  count               = var.create_log_analytics_workspace == false ? 0 : 1
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
  location            = var.location
}

module "monitor-azurevm" {
  source                     = "../alerts"
  query_alerts               = var.azurevm-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_azurevm
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-azuresql" {
  source                     = "../alerts"
  query_alerts               = var.azuresql-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_azuresql
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-logicapps" {
  source                     = "../alerts"
  query_alerts               = var.logicapps-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_logicapps
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-backups" {
  source                     = "../alerts"
  query_alerts               = var.backup-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_backup
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-aci" {
  source                     = "../alerts"
  query_alerts               = var.aci-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_aci
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-agw" {
  source                     = "../alerts"
  query_alerts               = var.agw-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_agw
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-azurecdn" {
  source                     = "../alerts"
  query_alerts               = var.azurecdn-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_azurecdn
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-azurefunction" {
  source                     = "../alerts"
  query_alerts               = var.azurefunction-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_azurefunction
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-datafactory" {
  source                     = "../alerts"
  query_alerts               = var.datafactory-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_datafactory
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-expressroute" {
  source                     = "../alerts"
  query_alerts               = var.expressroute-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_expressroute
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-lbadv" {
  source                     = "../alerts"
  query_alerts               = var.lbadv-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_lbadv
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}

module "monitor-lbstd" {
  source                     = "../alerts"
  query_alerts               = var.lbstd-query.query_alert_default
  deploy_monitoring          = var.deploy_monitoring_lbstd
  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
  l                          = var.location
  ag                         = azurerm_monitor_action_group.action_group
}