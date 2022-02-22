output "location" {
  value = var.location
}

output "deployed_snow_logic_app" {
  value = {
    principal_id   = module.snow_logicapp.logic_app_principal_id
    app_id         = module.snow_logicapp.logic_app_id
    callback_url   = module.snow_logicapp.logic_app_callback_url
    roles_assigned = module.snow_logicapp.roles_assigned
  }
}

output "deployed_monitoring" {
  value = {
    action_groups = module.monitoring.deployed_action_groups
    metric_alerts = module.monitoring.deployed_metric_alerts
    quert_alerts  = module.monitoring.deployed_query_alerts
  }
}

output "deployed_tagging_logic_app" {
  value = {
    principal_id            = module.tagging_logicapp.logic_app_principal_id
    law_id                  = module.tagging_logicapp.law_id
    target_subscription_ids = module.tagging_logicapp.target_subscription_ids
    app_id                  = module.tagging_logicapp.logic_app_id
    tag_retrieval_interval  = module.tagging_logicapp.tag_retrieval_interval
    roles_assigned          = module.tagging_logicapp.roles_assigned
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
