# Deploy TE Azure Monitoring via Terraform

## General thoughts and expectations

- Switches to enable monitoring only for needed resource types
- Use log workspace and query alerts types on that log workspace
- Should be able to create custom alerts
- Metric alerts are supported just for custom alerts

## Monitoring modules usage

The TF code calls root module in ./modules/monitoring to deploy following resources:
- Action groups.
- Enable resource tags in monitoring (deploys Azure Function)
- Calls child module at ./modules/alerts for each monitoring alert bundle that is supposed to be deployed.
- Calls child module at ./modules/custom_metric_alerts for any metric alerts

### Module "alerts" and "custom_metric_alerts"

Code common for all alert bundles that creates alerts based on variable input.  
Called from "monitoring" module.
Alerts module is used for query based alerts
Custom metric alerts are used for metric based alerts

### Module "monitoring"

Input variables as defined in ./modules/monitoring/variables*.tf  
Each resource type monitoring bundle is defined in separate variables file - eg. variables_monitor_azuresql.tf

### Adding new alert bundle

#### Variable Template

Template for easy creation with Mustache https://mustache.github.io/  
file: ./variables_monitor_template.tftemp / Should work as a guidance / schema for new alert bunde definitions

- SHORT_NAME: example "azurevm"
- RESOURCE_TYPE: "Azure VM"
- RESOURCE_TYPE_NOSPACE: example "AzureVM"
- METRIC_NOSPACE: example "CPUUsage"
- METRIC: example "CPU Usage"

Then just fill in the queries and alert attributes.

#### TF Config

Add new module stanza added to ./modules/monitoring/main.tf:

module "monitor-azuresql" {  
  source                     = "../alerts"  
  query_alerts               = var.azuresql-query.query_alert_default  
  deploy_monitoring          = var.deploy_monitoring_azuresql  
  resource_group_name        = var.log_analytics_workspace_resource_group
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  l                          = var.location  
  ag                         = azurerm_monitor_action_group.action_group  
}

By default new alert bundles are not deployed (if template variables_monitor_template.tftemp is used as source), so to deploy new bundle add a switch as in example file ./deploy.tf like:

deploy_monitoring_backup = true  

Then initialize new module in Terraform by running terraform init.

## To do

* Exceptions - timeframe when no alerts are generated


