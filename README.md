# Deploy TE Azure Monitoring via Terraform

## General information

Contains set of terraform modules:  
* Tagging function app  
* Monitoring  
* Alert_query  
* Alert_metric  

### Terraform module Tagging function app 
- Deploys the function app into subscription with shared log workspace  
- Function app code is deployed from this url: https://github.com/tieto-public-cloud/az-func-monitoring-tagging.git 
- Function app needs will read resource tags in target subscription and store them temporarily in storage account table ResTags, this will be updated once in hour.  
- Function app will also forward data from temporary storage into shared log workspace each minute and store them in custom log table TagData_CL  
- Function app need following permissions:
        - Read on target subscription  
        - Contributor on resource group with itself  
        - Contributor on resource group with shared log analytics workspace  
- It is possible specify whether to assign permissions to the function or not (in case the deployment service principal has such rights to assign permission)  

### Terraform module Monitoring
- Deploys chosen default alert bundles to shared log analytics workspace
- Deploys custom query alerts  
These should be specified as needed with following considerations:  
        - If alert has same name as one in default bundle it will override default alert  
        - If alert has unused name, it will create new alert  
- Deploys custom metric alerts – these should be specified as needed.  
- Deploys action groups  

### Module "alert_query" and "alert_metric"

Query alert: https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_query?ref=v1.0
Metric alert: https://github.com/tieto-public-cloud/az-tf-monitoring//modules/alert_metric?ref=v1.0

Code common for all alert bundles that creates alerts based on variable input.  
Called from "monitoring" module.
Alerts module is used for query based alerts
Custom metric alerts are used for metric based alerts

## Input Variables

### Tagging function app module

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
| assign_functionapp_perms | bool | Set to false if TF does not have permissions to assign IAM roles | true |


### Monitoring module

Each resource type monitoring bundle is defined in separate variables file - eg. variables_monitor_azuresql.tf

| Variable | Format | Description | Default |
|---|---|---|---|
| log_analytics_workspace_resource_group | string | The log Analytics Workspace resource group name | null |
| log_analytics_workspace_name | string | The log Analytics Workspace Name | null |
| location | string | The location/region to keep all your monitoring resources. | null |
| common_tags | map | Map of Default Tags | null |
| deploy_action_groups | bool | Switch to set if action groups should be deployed | true |
| action_groups | map | Action Group Config | https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_action_groups.tf |
| deploy_monitoring_<alert bundle*> | bool | Whether to deploy Monitoring alerts related to <alert bundle*> | false |
| <alert bundle*>_query | map | <alert bundle*> config for query based monitoring | example: https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_monitor_azurevm.tf |
| <alert bundle*>_custom_query | map | <alert bundle*> config for custom queries - does not have default values and is expected to be passed from root module this is merged with <alert bundle*>_query default bundle | null |
| deploy_custom_metric_alerts | bool | Whether to deploy Monitoring custom metric alerts | false |
| custom_metric_alerts | map | Locally present alerts | schema: https://github.com/tieto-public-cloud/az-tf-monitoring/blob/master/modules/monitoring/variables_monitor_metric_alerts.tf |

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

## Implemented baselines

### Tag driven baselines for Azure VM

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

### Other baselines

There are 2 files inside folder report-alerts. 
* report-alerts.ps1 contains script that can pull all alerts deployed on a resource group. 
* deployed-alerts-list.csv lists all deployed alerts currently implemented in default bundles with their thresholds, queries etc.

Any custom baselines that are not implemented in default bundles can be deployed via 
### Adding new alert baseline bundle

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
