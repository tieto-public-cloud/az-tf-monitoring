# Get subscription data for both subscriptions used in this example.
# We will be deploying the monitoring set up in the first one and
# any other supporting functions in the second one. They may or may
# not be identical.
data "azurerm_subscription" "mgmthub" {
  provider = azurerm.mgmthub
}

data "azurerm_subscription" "monexec" {
  provider = azurerm.monexec
}

# Declare some helpful locals, show examples of various customizations
# supported by these modules.
locals {
  # Module version, not used when using local source starting with "./modules"
  module_version = "v2.0"

  # Some tags applied to all newly deployed resources.
  common_tags = merge(
    var.common_tags,
    var.monitored_tags # We want to monitor whatever we deploy here.
  )
}

module "tag_driven_monitoring" {
  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=${local.module_version}"
  ## where ${local.module_version} is a git repository reference to a tagged version of the code, for example "v2.0".
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/monitoring"

  ## !!WARN!!
  ##
  ## Remove this line when deploying the module. The module and its submodules should be
  ## pulled directly from its source repository on Github, unless you are doing some development
  ## on the module itself.
  ##
  ## !!WARN!!
  submodule_source = "local"

  ## The module expect two providers, mapping must be provided explicitly!
  providers = {
    azurerm.law  = azurerm.mgmthub
    azurerm.exec = azurerm.monexec
  }

  ## Location must be shared by all resources, only regional deployments are supported.
  location  = var.location

  ## Which Log Analytics Workspace will be used as the source of data. It must exist beforehand!
  law_name           = var.mgmt_law_name
  law_resource_group = var.mgmt_law_resource_group

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

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags
}
