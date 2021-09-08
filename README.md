# Deploy TE Azure Monitoring via Terraform

## General thoughts and expectations

- We should be able to deploy monitoring only for needed resource types
- By default we use log workspace and query alerts types on that log workspace
- We should be able to create custom alerts (even the metric ones for custom alerts should be possible)
- Metric alerts should be able to be scoped and not expect to use all available subscriptions for deployment

## Monitoring modules usage

The TF code calls root module in ./modules/monitoring to deploy following resources:
- If needed - Resource group and Log Analytics Workspace.
- Action groups.
- Enable resource tags in monitoring if switched on.
- Calls child module at ./modules/alerts for each monitoring alert bundle that is supposed to be deployed.

### Module "monitoring"

Input variables as defined in ./modules/monitoring/variables*.tf
Each resource type monitoring bundle is defined in separate variables file - eg. variables_monitor_azuresql.tf

### Adding new alert bundle

#### Variable Template
Template for easy creation with Mustache https://mustache.github.io/
file: variables_monitor_template.tftemp / Should work as a guidance / schema for new alert bunde definitions

- SHORT_NAME: example "azurevm"
- RESOURCE_TYPE: "Azure VM"
- RESOURCE_TYPE_NOSPACE: example "AzureVM"
- METRIC_NOSPACE: example "CPUUsage"
- METRIC: example "CPU Usage"

Then just fill in the queries and alert attributes.

#### TF Config

Add new module stanza added to ./modules/monitoring/main.tf:

`module "monitor-azuresql" {`
`  source                     = "../alerts"`
`  query_alerts               = var.azuresql-query.query_alert_default`
`  deploy_monitoring          = var.deploy_monitoring_azuresql`
`  resource_group_name        = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)`
`  log_analytics_workspace_id = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)`
`  l                          = var.location`
`  ag                         = azurerm_monitor_action_group.action_group`
`}`

By default new alert bundles are not deployed (if template variables_monitor_template.tftemp is used as source), so to deploy new bundle add a switch to ./deploy.tf file:

`deploy_monitoring_backup = true`

Then initialize new module in Terraform by running terraform init.

## To do

* Merging custom metrics, currently only default ones available (these can be modified by passing from main Terraform folder)
* Switch to standard metrics if Tags are not used in monitoring (in case all objects reporting to log workspace are monitored there is no need to use tags - this is questionable if we going to use this)
* Support for metric alerts (with scoping etc)



