# Deploy all Azure Monitor query based alert rules.
resource "azurerm_monitor_scheduled_query_rules_alert" "query_alert" {
  for_each = var.deploy ? toset(var.query_alerts) : toset([])

  resource_group_name = var.law_resource_group_name
  location            = var.location
  data_source_id      = var.law_id

  name        = each.value.name
  description = each.value.name
  frequency   = each.value.frequency
  query       = each.value.query
  time_window = each.value.time_window
  enabled     = each.value.enabled
  severity    = each.value.severity
  throttling  = each.value.throttling

  trigger {
    operator  = each.value.trigger.operator
    threshold = each.value.trigger.threshold

    dynamic "metric_trigger" {
      for_each = each.value.trigger.metric_trigger == null ? [] : [1]

      content {
        operator            = each.value.trigger.metric_trigger.operator
        threshold           = each.value.trigger.metric_trigger.threshold
        metric_trigger_type = each.value.trigger.metric_trigger.type
        metric_column       = each.value.trigger.metric_trigger.column
      }
    }
  }

  # Attach to an existing action group created outside of this module and passed
  # down as a parameter. Match by name.
  action {
    action_group = [
      var.action_groups[index(var.action_groups.*.name, each.value.action_group)].id
    ]
  }

  # This could take a long time, extend default timeouts.
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
