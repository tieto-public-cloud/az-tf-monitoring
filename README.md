# Azure Monitoring via Terraform

## General information
This repository contains a set of Terraform modules:  
* `monitoring` - the main module referencing/using all other submodules.
* `tagging_logicapp` - a module deploying Azure Logic App reading resource tags from subscriptions and submitting them to LAW.

Unless you know exactly what you are doing, you should use these modules as shown in the example provided in the root
of this repository.

### Terraform Providers
The following examples work with two AzureRM provider instances. You need to be careful when working in multi-provider
environments and explicitly assign needed providers to specific resources and/or modules.

These examples are using:
```hcl
# For resources and modules working with the shared Log Analytics Workspace.
# Alert rules and action groups will be deployed here.
provider "azurerm" {
  features {}
  alias = "law"
}

# For supporting resources, such as Logic Apps.
# SNow Logic App and Tagging Logic App will be deployed here.
provider "azurerm" {
  features {}
  alias = "aux"
}
```

If you do not need to separate these resources into different Azure subscriptions, you can use one provider and
share it with modules and resources implicitly. That means WITHOUT:
```hcl
providers = {
    azurerm = azurerm.ALIAS_HERE
  }
```
in your resource and module definitions.

## SNow Logic App Module
- Deploys Azure Logic App into the specified subscription(s).
- The app will receive alert notifications from `monitoring` convert them from `AzureCommonAlert` schema to ServiceNow schema.
- Converted notification will be sent as events to the provided HTTPS endpoint (Webhook URL).

### Event Format
```json
{
  "description": "VARIABLES_HERE",
  "event_class": "VARIABLES_HERE",
  "metric_name": "VARIABLES_HERE",
  "node": "VARIABLES_HERE",
  "resource": "VARIABLES_HERE",
  "severity": "VARIABLES_HERE",
  "source": "Microsoft Azure v2",
  "time_of_event": "VARIABLES_HERE",
  "type": "VARIABLES_HERE",
  "additional_info" : "{ \"u_external_event_id\": \"ID_HERE\", \"u_external_event_url\": \"URL_HERE\" }"
}
```

### App Definition
See [Schema](modules/snow_logicapp/files/logicapp_workflow_schema.json).

### Input Variables
```hcl
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = {}
}

module "snow_logicapp" {
  source    = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/snow_logicapp?ref=v2.0"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the app and provide a resource group to use.
  name                = var.snow_la_name
  resource_group_name = azurerm_resource_group.la_rg.name
  location            = azurerm_resource_group.la_rg.location

  ## Provide a reference to the shared analytics workspace that will produce alerts.
  law_id = azurerm_log_analytics_workspace.law.id

  ## Configure SNow details. This URL should NOT point to a transform script, just the native JSON EventManagement endpoint.
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
```

## Tagging Logic App Module
- Deploys Azure Logic App into the specified subscription(s).
- The app will read resource tags from resources in the target subscription(s) and push them into a shared log analytics workspace.

### App Definition
See [Schema](modules/tagging_logicapp/files/logicapp_workflow_schema.json).

### Input Variables
```hcl
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = {}
}

module "tagging_logicapp" {
  source    = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/tagging_logicapp?ref=v2.0"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the app and provide a resource group to use.
  name                = var.tagging_la_name
  resource_group_name = azurerm_resource_group.la_rg.name
  location            = azurerm_resource_group.la_rg.location

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
```

## Monitoring Module
- Deploys default action groups.
- Deploys chosen default alert bundles to a shared log analytics workspace.
- *[Advanced]* Deploys custom action groups – these should be specified as needed.
- *[Advanced]* Deploys custom log query alerts – these should be specified as needed.
- *[Advanced]* Deploys custom metric alerts – these should be specified as needed.

### Input Variables
```hcl
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = {}
}

module "monitoring" {
  source    = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=v2.0"

  ## The module a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.law
  }

  ## Location must be shared by all resources, only regional deployments are supported.
  location  = azurerm_resource_group.law_rg.location

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
    "tagging_logicapp", ## To monitor resources deployed by this module.
    "snow_logicapp"     ## To monitor resources deployed by this module.
  ]

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  ## Make sure everything is executed in the right order.
  depends_on = [
    azurerm_log_analytics_workspace.law,
    module.snow_logicapp,
    module.tagging_logicapp
  ]
}
```

For more details, refer to the example provided in the root of the repository (top-level `*.tf` files) or variables defined in
all `variables*.tf` files in [the monitoring module](modules/monitoring/).

### Supported Alert Bundles
- App Gateway - `agw`
- Azure Function - `azurefunction`
- Azure SQL - `azuresql`
- Azure VM - `azurevm`
- Backup - `backup`
- DataFactory - `datafactory`
- Express Route - `expressroute`
- Load Balancer - `lb`
- Logic App - `logicapp`

### Implemented baselines
For a list of baselines provided by default alert bundles for each resource type, refer to
local variables available in [the monitoring module](modules/monitoring/).

Any custom baselines that are not implemented in default alert bundles can be deployed via:
- `*_log_signals`
- `metric_signals`
These are *advanced* parameters of the `monitoring` module. Refer to the provided examples
for details.

## Changelog
See [CHANGELOG.md](CHANGELOG.md).

## Contribute
1. Fork it.
2. Create a branch (git checkout -b my_markup).
3. Commit your changes (git commit -am "My changes").
4. Push to the branch (git push origin my_markup).
5. Create an Issue with a link to your branch.

### Adding Resource Alert Bundle
To add an alert bundle for a new resource type, you can use any of the existing ones as a guide.

You need to add a new module stanza to [modules/monitoring/main.tf](modules/monitoring/main.tf):
```hcl
locals {
  # All available bundles have to be explicitly registered here.
  all_log_signals = {
    azurevm             = local.azurevm_log_signals
    azuresql            = local.azuresql_log_signals
    backup              = local.backup_log_signals
    agw                 = local.agw_log_signals
    azurefunction       = local.azurefunction_log_signals
    datafactory         = local.datafactory_log_signals
    expressroute        = local.expressroute_log_signals
    lb                  = local.lb_log_signals
    tagging_logicapp = local.tagging_logicapp_log_signals
  }

  # ...
}
```

You also need to add a new `variables_monitor_*.tf` to [modules/monitoring/](modules/monitoring/) that
matches the name of the new resource. See existing resource variables for the required layout of that file.

## Disclaimer
This is not an official Tietoevry product.