
module "monitoring-alert" {
  source                                 = "./modules/monitoring"
  location                               = "westeurope"
  log_analytics_workspace_name           = "log-te-custz-test"
  log_analytics_workspace_resource_group = "rg-teshared-custz-test"

  # Resource tagging related switches
  storage_account_name      = "dbartossa"
  monitor_tagging_fapp_name = "fa-te-custz-test"
  use_resource_tags         = true

  # Switches enabling different resource types monitoring - as per: https://confluence.shared.int.tds.tieto.com/display/PCCD/Azure+Monitoring+Baseline
  deploy_monitoring_azurevm = true
  #azurevm_custom_query = var.azurevm_custom_query
  deploy_monitoring_azuresql      = true
  deploy_monitoring_logicapps     = true
  deploy_monitoring_backup        = true
  deploy_monitoring_agw           = true
  deploy_monitoring_azurefunction = true

  # Following ones does not have queries defined yet so this is just a placeholder at the moment
  deploy_monitoring_azurecdn     = false
  deploy_monitoring_datafactory  = false
  deploy_monitoring_expressroute = false
  deploy_monitoring_lbadv        = false
  deploy_monitoring_lbstd        = false

}

