
module "monitoring-alert" {
  source                                 = "./modules/monitoring"
  location                               = "westeurope"
  log_analytics_workspace_name           = "log-te-custz-test"
  log_analytics_workspace_resource_group = "rg-teshared-custz-test"
  
  # Resource tagging related switches
  storage_account_name                   = "dbartossa"
  monitor_tagging_fapp_name              = "fa-te-custz-test"
  use_resource_tags                      = true

  # Switches enabling different resource types monitoring
  deploy_monitoring_azurevm              = true
  deploy_monitoring_azuresql             = true
  deploy_monitoring_logicapps            = true
  deploy_monitoring_backup = true
}

