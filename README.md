# Azure Monitoring via Terraform

## General information
This repository contains a set of Terraform modules:  
* `monitoring` - the main module referencing/using all other submodules.
* `tagging_functionapp` - a module deploying Azure Function apps reading resource tags from subscriptions and submitting them to LAW.

Unless you know exactly what you are doing, you should use these modules as shown in the example provided in the root
of this repository.

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
  monitor = [
    "azurevm",
    # "azuresql",
    # "backup",
    # "agw",
    # "azurefunction",
    # "datafactory",
    # "expressroute",
    # "lb",
    "tagging_functionapp" ## To monitor resources deployed by this module.
  ]

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

## Tagging Function App Module
- Deploys Azure Function app(s) into the specified subscription.
  - The app is deployed from: https://github.com/tieto-public-cloud/az-func-monitoring-tagging
  - The app will read resource tags from resources in the target subscription and push them into a shared log analytics workspace.

### Input Variables
```hcl
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = {}
}

module "tagging_functionapp" {
  source    = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/tagging_functionapp?ref=v2.0"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the function and provide a resource group to use.
  name                = var.fa_name
  resource_group_name = azurerm_resource_group.fa_rg.name

  ## Azure is picky about SA names, be sure to provide a valid value here!
  storage_account_name = replace("${var.fa_name}sa","/[^a-z0-9]/","")

  location                = var.location
  law_name                = var.law_name
  law_resource_group_name = azurerm_resource_group.law_rg.name
  law_id                  = azurerm_log_analytics_workspace.law.id

  ## Provide a subscription to read.
  target_subscription_id = var.target_subscription_id

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
    tagging_functionapp = local.tagging_functionapp_log_signals
  }

  # ...
}
```

You also need to add a new `variables_monitor_*.tf` to [modules/monitoring/](modules/monitoring/) that
matches the name of the new resource. See existing resource variables for the required layout of that file.
