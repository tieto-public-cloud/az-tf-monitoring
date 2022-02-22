# Declare some helpful locals, show examples of various customizations
# supported by these modules.
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = merge(
    var.common_tags,
    var.monitored_tags # We want to monitor whatever we deploy here.
  )

  # For sandbox VMs. See `sandbox.tf` for details.
  unsafe_user   = "adminuser"
  unsafe_passwd = "Azur3M33tupF3b!"
}

## See `sandbox.tf` for resources deployed to test these modules.

##############################################################################
## Logic App for integration with SNow
##############################################################################

# Deploy a Logic App converting alerts and sending them to ServiceNow.
module "snow_logicapp" {
  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/snow_logicapp?ref=v2.0"
  ## where `v2.0` is a git repository reference to a tagged version of the code (a git tag).
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/snow_logicapp"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the app and provide a resource group to use.
  name                = var.snow_la_name
  resource_group_name = azurerm_resource_group.la_rg.name
  location            = var.location

  ## Provide a reference to the shared analytics workspace that will produce alerts.
  law_id = azurerm_log_analytics_workspace.law.id

  ## Configure SNow details.
  snow_webhook_url      = var.snow_webhook_url
  snow_webhook_username = var.snow_webhook_username
  snow_webhook_password = var.snow_webhook_password

  ## During the deployment, we need to adjust Azure RBAC assignments.
  ## If your deployment credentials don't have permission to do that,
  ## set this to `false` and look for principal IDs in the output so
  ## that you can assign roles manually.
  ##
  ## Look for:
  ## * principal_id             (this is the identity that needs roles below)
  ## * law_id                   (Log Analytics Reader)
  ##
  # assign_roles = true

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags
}

##############################################################################
## Tag retrieval Logic App
##############################################################################

# Deploy a Logic App pulling resource tags and sending them to the Log Analytics Workspace.
module "tagging_logicapp" {
  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/tagging_logicapp?ref=v2.0"
  ## where `v2.0` is a git repository reference to a tagged version of the code (a git tag).
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/tagging_logicapp"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the app and provide a resource group to use.
  name                = var.tagging_la_name
  resource_group_name = azurerm_resource_group.la_rg.name

  location         = var.location
  law_id           = azurerm_log_analytics_workspace.law.id
  law_workspace_id = azurerm_log_analytics_workspace.law.workspace_id
  law_primary_key  = azurerm_log_analytics_workspace.law.primary_shared_key

  ## Provide subscription(s) from which to read resource tags.
  target_subscription_ids = var.target_subscription_ids

  ## During the deployment, we need to adjust Azure RBAC assignments.
  ## If your deployment credentials don't have permission to do that,
  ## set this to `false` and look for principal IDs in the output so
  ## that you can assign roles manually.
  ##
  ## Look for:
  ## * principal_id             (this is the identity that needs roles below)
  ## * target_subscription_ids  (Reader)
  ##
  # assign_roles = true

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  ############################################################################
  ## Everything beyond this point is customization for experts.
  ############################################################################

  ## How often should helper function refresh data from target subscriptions?
  ## Doing this often can get expensive. Do not change this value unless you
  ## know what you are doing.
  # tag_retrieval_interval = 3 # in hours!
}

##############################################################################
## Monitoring set-up with alerts
##############################################################################

module "monitoring" {
  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=v2.0"
  ## where `v2.0` is a git repository reference to a tagged version of the code (a git tag).
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/monitoring"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.law
  }

  ## Location must be shared by all resources, only regional deployments are supported.
  location  = var.location

  ## Which Log Analytics Workspace will be used as the source of data. It must exist beforehand!
  law_name                = var.law_name
  law_resource_group_name = azurerm_resource_group.law_rg.name

  ## Change configuration of the default action group set up.
  ## Module deploys two webhook-based AGs by default:
  ## * tm-critical-actiongroup
  ## * tm-warning-actiongroup
  ag_default_logicapp_id           = module.snow_logicapp.logic_app_id
  ag_default_logicapp_callback_url = module.snow_logicapp.logic_app_callback_url
  # ag_default_use_common_alert_schema = true

  ## To choose what will be monitored. Everything is turned off by default.
  monitor = [
    "azurevm",
    # "azuresql",
    # "backup",
    # "agw",
    # "azurefunction",
    # "datafactory",
    # "expressroute",
    # "lb",
    # "tagging_logicapp" ## To monitor resources deployed by this module.
  ]

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  ############################################################################
  ## Everything beyond this point is customization for experts.
  ############################################################################

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

  ############################################################################
  ## This part is necessary only for the example, we need to
  ## wait for LAW to be created before we start deploying monitoring.
  ############################################################################
  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}
