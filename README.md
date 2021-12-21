# Deploy TE Azure Monitoring via Terraform

## General information

This terraform module provides deployment of Azure monitoring that supports following:

Architecture and workflow described here: https://confluence.shared.pub.tds.tieto.com/display/PCCD/Azure+Monitoring+with+Resource+Tags

- Switches to enable monitoring only for needed resource types and deploys only related monitoring alert bundles
- Creates query based alerts on log workspace
- If needed there is possibility to override default query bundle, or create custom queries as well
- Metric alerts are supported, no defaults only custom alerts
- Deploys Azure function that provide resource tags to Log Analytics Workspace that are used in queries to provide support for:
    - Filtering based on tags - te-managed-service: true or workload will enable monitoring of the specified resource
    - Ticket routing inside CMDG (Service Now)
    - Tag driven monitoring baselines - currently implemented for VMs - possible to specify tags:  

| Metric | Warning - Threshold | Warning - Period | Critical -Threshold | Critical - Period | Tag - Key | Tag - Value | Comments |
|---|---|---|---|---|---|---|---|
| CPU | 90 | 600 | 95 | 600 | default - no tags needed |  | standard fitting most VMs |
| CPU | 95 | 600 | 98 | 600 | monitoring_cpu | high | VMs with higher CPU usage |
| CPU | 90 | 1800 | 95 | 1800 | monitoring_cpu | slow | for VMs that runs long running processes that consume large amount of cpu but then coming back to normal (batch jobs etc) |
| Memory | 87 | 300 | 95 | 300 | default - no tags needed |  | standard fitting most VMs |
| Memory | 96 | 300 | 98 | 300 | monitoring_mem | high | for VMs with large memory usage footpring |
| Memory | 87 | 1800 | 95 | 1800 | monitoring_mem | slow | for VMs that runs long running processes that consume large amount of memory but then coming back to normal (batch jobs etc) |
| Disk | 80 | 60 | 90 | 60 | default - no tags needed |  | standard fitting most VMs |
| Disk | 90 | 900 | 95 | 60 | monitoring_disk (os or data) | high | for VMs with large disks |
| Disk | 94 | 900 | 97 | 60 | monitoring_disk (os or data) | highest | for VMs with extremely large disks |

## Monitoring modules usage

The TF code calls monitoring module in ./modules/monitoring to deploy following resources:
- Action groups.
- Enable resource tags in monitoring (deploys Azure Function and related infrastructure)
- Calls child module for each monitoring alert bundle that is supposed to be deployed.
- Calls child module for any metric alerts

### Module "alert_query" and "alert_metric"

Query alert: https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0
Metric alert: https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_metric?ref=v1.0

Code common for all alert bundles that creates alerts based on variable input.  
Called from "monitoring" module.
Alerts module is used for query based alerts
Custom metric alerts are used for metric based alerts

### Module "monitoring"

Each resource type monitoring bundle is defined in separate variables file - eg. variables_monitor_azuresql.tf
List of alerts is available here: https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/report-alerts/alerts-rg-teshared-custz-test.csv

#### Input Variables

| Variable | Format | Description | Default |
|---|---|---|---|
| log_analytics_workspace_resource_group | string | The log Analytics Workspace resource group name | null |
| log_analytics_workspace_name | string | The log Analytics Workspace Name | null |
| location | string | The location/region to keep all your monitoring resources. | null |
| storage_account_name | string | Name of storage account for Resource tagging function temp storage | null |
| monitor_tagging_fapp_rg | string | Resource group name with Resource tagging function | null |
| monitor_tagging_fapp_name | string | Name of Resource tagging function | null |
| monitor_tagging_function_repo | string | Source code repository URL for monitor tagging Azure Function | https://github.com/tieto-public-cloud/az-func-monitoring-tagging.git |
| common_tags | map | Map of Default Tags | null |
| action_groups | map | Action Group Config | https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_action_groups.tf |
| deploy_monitoring_<alert bundle*> | bool | Whether to deploy Monitoring alerts related to <alert bundle*> | false |
| <alert bundle*>_query | map | <alert bundle*> config for query based monitoring | example: https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_monitor_azurevm.tf |
| deploy_custom_metric_alerts | bool | Whether to deploy Monitoring custom metric alerts | false |
| custom_metric_alerts | map | Locally present alerts | schema: https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_monitor_metric_alerts.tf |
| assign_functionapp_perms | bool | Set to false if TF does not have permissions to assign IAM roles | true |

*alert bundle - currently supporting following: 
- App Gateway - agw
- Azure Function - azurefunction
- Azure SQL - azuresql
- Azure VM - azurevm
- Backup - backup
- DataFactory - datafactory
- Express Route - expressroute
- Load Balancer - lb
- Logic Apps - logicapps

### Adding new alert bundle

To add new alert bundle you can just use any of existing ones as a guidance as well as variable object definition available to create new alert bundle defaults.

#### TF Config

Add new module stanza added to ./modules/monitoring/main.tf:

        module "monitor-azuresql" {  
          source                     = "https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0"  
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

## Azure function - resource tags data to log analytics workspace

### General Info
We needed to use resource tags with Azure Monitor query based alerts to make easier use of:

1. Monitoring baselines
2. Routing tickets to specific team in our CMDB
3. Filter resources that we are interested in monitoring (as a service provider)

Powershell based Azure function that reads subscription resources tags data and stores it to specified log analytics workspace custom log data.
The function reads configuration from Azure storage account table service (table name Config), also uses this storage account as a temporary storage.

__Repo URL: https://github.com/tieto-public-cloud/az-func-monitoring-tagging__

### Function workflow
Due to cost optimization I had decided to make function operate in 2 stages. The function is executed as a scheduled trigger each minute.

#### Stage 1
This stage is initiated if difference between now and time of creation of the temporary record is greater than Delta configuration property value (or there are not any temporary data stored yet)
Removes temporary data from ResTags table in specified storage account
Read resource tags data from subscription where function resides. This should happen once in hour (actually configurable via Delta configruation property) as this operation is quite compute heavy and takes most of the time
Store data in temporary storage

#### Stage 2
Reads ResTags table content and push it to log analytics workspace
