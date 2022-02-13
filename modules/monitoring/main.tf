##############################################################################
## Creates common monitoring set up - action groups - and delegates the
## rest to other modules.
##
## Delegated:
## * Creation of log query based alerts to alert_query.
## * Creation of metric based alerts to metric_query.
## * Creation of a Function App pushing resource tags to LAW to tagging_functionapp.
##
##############################################################################

locals {
  module_public_repo  = "https://github.com/tieto-public-cloud/az-tf-monitoring"
  module_source_gh    = "git::${local.module_public_repo}//modules"
  module_source_local = ".."

  module_source_aq = var.submodule_source == "remote" ? "${local.module_source_gh}/alert_query?ref=${var.submodule_version}" : "${local.module_source_local}/alert_query"
  module_source_am = var.submodule_source == "remote" ? "${local.module_source_gh}/alert_metric?ref=${var.submodule_version}" : "${local.module_source_local}/alert_metric"
  module_source_fa = var.submodule_source == "remote" ? "${local.module_source_gh}/tagging_functionapp?ref=${var.submodule_version}" : "${local.module_source_local}/tagging_functionapp"
}

data "azurerm_log_analytics_workspace" "law" {
  provider = azurerm.law

  name                = var.law_name
  resource_group_name = var.law_resource_group
}

##############################################################################
## Action Groups for Alerts
##############################################################################

# For Azure Monitor action groups, currently only webhook, email and ARM receivers
# are supported but other receivers can be added to the code easily following
# the existing pattern.
resource "azurerm_monitor_action_group" "action_group" {
  provider = azurerm.law
  for_each = toset(local.action_groups) # See variables_action_groups.tf for locals.

  name                = each.value.name
  resource_group_name = var.law_resource_group
  short_name          = each.value.short_name

  dynamic "webhook_receiver" {
    for_each = each.value.webhook == null ? [] : [1]

    content {
      name                    = each.value.webhook.name
      service_uri             = each.value.webhook.service_uri
      use_common_alert_schema = each.value.webhook.use_common_alert_schema
    }
  }

  dynamic "email_receiver" {
    for_each = each.value.email == null ? [] : [1]

    content {
      name                    = each.value.email.name
      email_address           = each.value.email.email_address
      use_common_alert_schema = each.value.email.use_common_alert_schema
    }
  }

  dynamic "arm_role_receiver" {
    for_each = each.value.arm_role_receiver == null ? [] : [1]

    content {
      name                    = each.value.arm_role_receiver.name
      role_id                 = each.value.arm_role_receiver.role_id
      use_common_alert_schema = each.value.arm_role_receiver.use_common_alert_schema
    }
  }

  # Attach common tags passed from the caller.
  tags = local.common_tags

  # This could take a long time, extend default timeouts.
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

##############################################################################
## Log Query Alerts
##############################################################################

module "azurevm_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.azurevm_log_signals
  deploy                  = var.monitor_azurevm
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "azuresql_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.azuresql_log_signals
  deploy                  = var.monitor_azuresql
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "logicapp_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.logicapp_log_signals
  deploy                  = var.monitor_logicapp
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "backup_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.backup_log_signals
  deploy                  = var.monitor_backup
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "agw_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.agw_log_signals
  deploy                  = var.monitor_agw
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "azurefunction_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.azurefunction_log_signals
  deploy                  = var.monitor_azurefunction
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "datafactory_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.datafactory_log_signals
  deploy                  = var.monitor_datafactory
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "expressroute_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.expressroute_log_signals
  deploy                  = var.monitor_expressroute
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

module "lb_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.lb_log_signals
  deploy                  = var.monitor_lb
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

##############################################################################
## Metric Alerts
##############################################################################

# Right now, there are no pre-defined metric alerts. Only metric alerts
# provided by the caller will be deployed.
module "custom_metric_alerts" {
  source    = local.module_source_am
  providers = {
    azurerm = azurerm.law
  }

  law_resource_group_name = var.law_resource_group
  deploy                  = true
  metric_alerts           = local.metric_signals
  action_groups           = azurerm_monitor_action_group.action_group
}

##############################################################################
## Tagging Function App
##############################################################################

# Deploy monitoring on self.
module "tagging_functionapp_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.tagging_functionapp_log_signals
  deploy                  = var.monitor_tagging_functionapp
  law_resource_group_name = var.law_resource_group
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}

# Deploy a Function App pulling resource tags and sending them to the Log Analytics Workspace.
module "tagging_functionapp" {
  source    = local.module_source_fa
  providers = {
    azurerm = azurerm.exec
  }

  location                               = var.location
  log_analytics_workspace_name           = var.law_name
  log_analytics_workspace_resource_group = var.law_resource_group
  target_subscription_id                 = "3a60e7b7-ac49-45d8-8a8f-ba61cdc5dc1f"
  monitor_tagging_fapp_name              = "fa-temonfa-test"
  monitor_tagging_fapp_rg                = "rg-temonfa-test"
  storage_account_name                   = "fatemptestsa"
  common_tags                            = local.common_tags
}
