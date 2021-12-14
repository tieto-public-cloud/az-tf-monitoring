locals {
  # Build an array of all Azure Monitor query-based alert rules.  A number of rules can be configured and they are
  # configured to Azure Monitor in each location.
  monitor_query_alert_deployments = [
    for n, p in var.query_alerts : {
      query_alert_name = n
      query_alert      = p
    }
  ]
}

resource "azurerm_monitor_scheduled_query_rules_alert" "query_alert" {

  # Deploy all Azure Monitor query-based alert rules.
  for_each = var.deploy_monitoring ? {
    for k in local.monitor_query_alert_deployments : k.query_alert_name => k
  } : {}


  name                = each.value.query_alert.name
  resource_group_name = var.resource_group_name
  location            = var.l
  data_source_id      = var.log_analytics_workspace_id
  description         = each.value.query_alert.name
  frequency           = each.value.query_alert.frequency
  query               = each.value.query_alert.query
  time_window         = each.value.query_alert.time_window
  enabled             = each.value.query_alert.enabled
  severity            = each.value.query_alert.severity
  throttling          = each.value.query_alert.throttling

  trigger {
    operator  = each.value.query_alert.trigger.operator
    threshold = each.value.query_alert.trigger.threshold

    dynamic "metric_trigger" {
      for_each = each.value.query_alert.trigger.metric_trigger == null ? [] : [1]

      content {
        operator            = each.value.query_alert.trigger.metric_trigger.operator
        threshold           = each.value.query_alert.trigger.metric_trigger.threshold
        metric_trigger_type = each.value.query_alert.trigger.metric_trigger.type
        metric_column       = each.value.query_alert.trigger.metric_trigger.column
      }
    }
  }

  action {
    action_group = [
      var.ag[each.value.query_alert.action_group].id
    ]
  }
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
