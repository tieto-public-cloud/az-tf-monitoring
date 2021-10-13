
module "monitoring-alert" {
  source                                 = "./modules/monitoring"
  location                               = "westeurope"
  log_analytics_workspace_name           = "log-te-custz-test"
  log_analytics_workspace_resource_group = "rg-teshared-custz-test"

  # Resource tagging related switches
  monitor_tagging_fapp_name = "fa-te-custz-test"
  monitor_tagging_fapp_rg   = "rg-temonfa-custz-test"
  storage_account_name      = "fatecustztestsa"
#  use_resource_tags         = true

  # Common tags
  common_tags = var.common_tags

  # Switches enabling different resource types monitoring - as per: https://confluence.shared.int.tds.tieto.com/display/PCCD/Azure+Monitoring+Baseline
  deploy_monitoring_azurevm       = true
  deploy_monitoring_azuresql      = true
  deploy_monitoring_logicapps     = true
  deploy_monitoring_backup        = true
  deploy_monitoring_agw           = true
  deploy_monitoring_azurefunction = true
  deploy_monitoring_datafactory   = true
  deploy_monitoring_expressroute  = true
  deploy_monitoring_lb = true

  # Pass on custom query variables
  #azurevm_custom_query = var.azurevm_custom_query
}

