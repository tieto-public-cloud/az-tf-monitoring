output "location" {
  value = var.location
}

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

output "law" {
  value = {
    law_name           = var.law_name
    law_resource_group = azurerm_resource_group.law_rg.name
    law_id             = azurerm_log_analytics_workspace.law.id
  }
}

output "sandbox" {
  value = {
    linux = {
      ip     = azurerm_network_interface.sb_linux_intf.private_ip_address
      user   = local.unsafe_user
      passwd = local.unsafe_passwd
    }
    win   = {
      ip     = azurerm_network_interface.sb_win_intf.private_ip_address
      user   = local.unsafe_user
      passwd = local.unsafe_passwd
    }
  }
}
