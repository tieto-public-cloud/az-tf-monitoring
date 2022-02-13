# Declare some helpful locals, show examples of various customizations
# supported by these modules.
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = merge(
    var.common_tags,
    var.monitored_tags # We want to monitor whatever we deploy here.
  )
}

resource "azurerm_resource_group" "law_rg" {
  name     = var.law_resource_group_name
  location = var.location

  tags     = local.common_tags
  provider = azurerm.law
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = azurerm_resource_group.law_rg.location
  resource_group_name = azurerm_resource_group.law_rg.name

  retention_in_days = 7

  tags     = local.common_tags
  provider = azurerm.law
}

module "tag_driven_monitoring" {
  source    = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=v2.0"

  ## The module expect two providers, mapping must be provided explicitly!
  providers = {
    azurerm.law = azurerm.law
    azurerm.aux = azurerm.aux
  }

  ## Location must be shared by all resources, only regional deployments are supported.
  location  = var.location

  ## Which Log Analytics Workspace will be used as the source of data. It must exist beforehand!
  law_name                = var.law_name
  law_resource_group_name = var.law_resource_group_name

  ## Change configuration of the default action group set up.
  ## Module deploys two webhook-based AGs by default:
  ## * tm-critical-actiongroup
  ## * tm-warning-actiongroup
  ag_default_webhook_service_uri = var.snow_webhook_uri
  # ag_default_use_common_alert_schema = true

  ## To choose what will be monitored. Everything is turned off by default.
  monitor_azurevm = true
  # monitor_azuresql      = false
  # monitor_logicapp      = false
  # monitor_backup        = false
  # monitor_agw           = false
  # monitor_azurefunction = false
  # monitor_datafactory   = false
  # monitor_expressroute  = false
  # monitor_lb            = false

  ## To monitor itself! Enabled by default.
  # monitor_tagging_functionapp = true

  ## To push tag data to LAW, we need helper functions.
  ## One Azure Function app will be deployed for each target subscription.
  fa_resource_group_name  = var.fa_resource_group_name
  fa_name                 = var.fa_name
  target_subscription_ids = var.target_subscription_ids

  ## During the deployment, we need to adjust Azure RBAC assignments.
  ## If your deployment credentials don't have permission to do that,
  ## set this to `false` and look for principal IDs in the output so
  ## that you can assign roles manually.
  ##
  ## Look for:
  ## * principal_id             (this is the identity that needs roles below)
  ## * storage_account_id       (Storage Account Contributor)
  ## * law_id                   (Log Analytics Contributor)
  ## * target_subscription_id   (Reader)
  ##
  # assign_roles = true

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  depends_on = [
    azurerm_resource_group.law_rg,
    azurerm_log_analytics_workspace.law
  ]

  #############################################################
  ## Everything beyond this point is customization for experts.
  #############################################################

  ## How often should helper function refresh data from target subscriptions?
  ## Doing this often can get expensive. Do not change this value unless you
  ## know what you are doing.
  # fa_tag_retrieval_interval = 3600

  ## Add any new action groups referenced from custom signals below here!
  # action_groups  = []

  ## Take care to reference only existing action groups (or add them above)!
  # azurevm_log_signals       = []
  # azuresql_log_signals      = []
  # logicapp_log_signals      = []
  # backup_log_signals        = []
  # agw_log_signals           = []
  # azurefunction_log_signals = []
  # datafactory_log_signals   = []
  # expressroute_log_signals  = []
  # lb_log_signals            = []

  ## Take care to reference only existing action groups (or add them above)!
  # metric_signals = []
}
