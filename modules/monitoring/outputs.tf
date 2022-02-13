output "deployed_action_groups" {
  value = values(azurerm_monitor_action_group.action_group)[*].id
}

output "deployed_metric_alerts" {
  value = module.custom_metric_alerts.deployed_metric_alerts
}

output "deployed_query_alerts" {
  value = {
    agw = module.agw_log_alerts.deployed_query_alerts
    azurefunction = module.azurefunction_log_alerts.deployed_query_alerts
    azuresql = module.azuresql_log_alerts.deployed_query_alerts
    azurevm = module.azurevm_log_alerts.deployed_query_alerts
    backup = module.backup_log_alerts.deployed_query_alerts
    datafactory = module.datafactory_log_alerts.deployed_query_alerts
    expressroute = module.expressroute_log_alerts.deployed_query_alerts
    lb = module.lb_log_alerts.deployed_query_alerts
    logicapp = module.logicapp_log_alerts.deployed_query_alerts
    tagging_functionapp = module.tagging_functionapp_log_alerts.deployed_query_alerts
  }
}

output "deployed_tagging_functionapps" {
  value = {
    for fapp_name, fapp in module.tagging_functionapp : fapp_name => {
      principal_id           = fapp.function_app_principal_id
      storage_account_id     = fapp.storage_account_id
      law_id                 = fapp.law_id
      target_subscription_id = fapp.target_subscription_id
      app_id                 = fapp.function_app_id
      tag_retrieval_interval = fapp.tag_retrieval_interval
    }
  }
}

# This is consistent across all tagging function apps, so outputing from a variable instead of a module output.
output "roles_assigned" {
  value = var.assign_roles ? "Yes" : "No"
}
