output "deployed_monitoring" {
  value = {
    action_groups = module.monitoring.deployed_action_groups
    metric_alerts = module.monitoring.deployed_metric_alerts
    quert_alerts  = module.monitoring.deployed_query_alerts
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
      roles_assigned         = fapp.roles_assigned
    }
  }
}
