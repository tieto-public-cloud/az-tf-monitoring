# Azure Monitoring via Terraform

## General information
This repository contains a set of Terraform (sub)modules:  
* `monitoring` - the main module referencing/using all other submodules.
* `tagigng_functionapp` - a submodule deploying Azure Function apps reading resource tags from subscriptions and submitting them to LAW.
* `alert_query` - a submodule deploying log query based alerts to LAW.
* `alert_metric` - a submodule deploying metric based alerts.

Unless you know exaclty what you are doing, you should use only the main `monitoring` module as shown in the example provided in the root
of this repository. Direct use of its submodules is discouraged and you will be doing it at your own peril.

## Monitoring Module
- Deploys default action groups.
- Deploys chosen default alert bundles to a shared log analytics workspace.
- Deploys Azure Function app(s) into the specified subscription.
  - The app is deployed from: https://github.com/tieto-public-cloud/az-func-monitoring-tagging
  - The app will read resource tags from resources in the target subscription and push them into a shared log analytics workspace.
- *[Advanced]* Deploys custom action groups – these should be specified as needed.
- *[Advanced]* Deploys custom log query alerts – these should be specified as needed.
- *[Advanced]* Deploys custom metric alerts – these should be specified as needed.

### Input Variables
```hcl
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = {}
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
This are *advanced* parameters of the `monitoring` module.

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
# In this example, change "azurevm" to match the name of the new resource.
module "azurevm_log_alerts" {
  source    = local.module_source_aq
  providers = {
    azurerm = azurerm.law
  }

  query_alerts            = local.azurevm_log_signals
  deploy                  = var.monitor_azurevm
  law_resource_group_name = var.law_resource_group_name
  law_id                  = data.azurerm_log_analytics_workspace.law.id
  location                = var.location
  action_groups           = azurerm_monitor_action_group.action_group
}
```

You also need to add a new `variables_monitor_*.tf` to [modules/monitoring/](modules/monitoring/) that
matches the name of the new resource. See existing resource variables for the required layout of that file.
