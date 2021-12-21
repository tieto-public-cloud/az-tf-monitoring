#
# Terraform requirements
#
terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">=1.0.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

#
# Call the monitoring alert module
#

module "monitoring-alert" {

  source                                 = "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=v1.1"
  location                               = "westeurope"
  log_analytics_workspace_name           = "log-te-custz-test"
  log_analytics_workspace_resource_group = "rg-teshared-custz-test"

  # Resource tagging function app related variables
  monitor_tagging_fapp_name = "fa-te-custz-test"
  monitor_tagging_fapp_rg   = "rg-temonfa-custz-test"
  storage_account_name      = "fatecustztestsa"

  # Common tags
  common_tags = {
    "environment"        = "tagged monitoring test infra"
    "owner"              = "bartpdav"
    "te-managed-service" = "workload"
  }

  # Switches enabling different resource types monitoring

  deploy_monitoring_azurevm       = true
  # deploy_monitoring_azuresql      = true
  # deploy_monitoring_logicapps     = true
  # deploy_monitoring_backup        = true
  # deploy_monitoring_agw           = true
  # deploy_monitoring_azurefunction = true
  # deploy_monitoring_datafactory   = true
  # deploy_monitoring_expressroute  = true
  # deploy_monitoring_lb            = true

  # # Pass on custom query variables if needed - see terraform_custom_alerts.auto.tfvars file for a reference
  # # File contains example of custom query based alerts and also custom metric based alerts
  # azurevm_custom_query = var.azurevm_custom_query

  # In case of need you can deploy metric alerts defined in custom_metric_alerts variable
  # deploy_custom_metric_alerts = false

  # !!! There must always be some alert passed over to monitoring module !!!
  # even if deploy_custom_metric_alerts is false or not set (as it has false set by default)

  custom_metric_alerts = {
    "dummy" = {
      enabled                  = false
      auto_mitigate            = true
      description              = "Dummy metric alert"
      frequency                = "PT5M"
      severity                 = 0
      target_resource_type     = "Microsoft.Compute/virtualMachines"
      action_group             = "tm-warning-actiongroup"
      target_resource_location = "westeurope"
      scope                    = data.azurerm_subscription.current.id
      window_size              = "PT5M"
      criteria = {
        metric_namespace = "Microsoft.Compute/virtualMachines"
        metric_name      = "CPU Credits Consumed"
        aggregation      = "Count"
        operator         = "GreaterThan"
        threshold        = 100
      }
    }
  }
}


