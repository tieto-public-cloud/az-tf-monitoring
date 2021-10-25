locals {
  # Build an array of all Azure Monitor metric alert rules.  A number of rules can be configured and they are
  # configured to Azure Monitor.
  monitor_metric_alert_deployments = [
    for n, p in var.metric_alerts : {
      metric_alert_name = n
      metric_alert      = p
    }
  ]
}

resource "azurerm_monitor_metric_alert" "metric_alerts" {

  # Deploy all Azure Monitor query-based alert rules.
  for_each = var.deploy_monitoring ? {
    for k in local.monitor_metric_alert_deployments : k.metric_alert_name => k
  } : {}

  name                = each.value.metric_alert_name
  resource_group_name = var.resource_group_name
  scopes              = [each.value.metric_alert.scope]
  description         = each.value.metric_alert.description
  enabled = each.value.metric_alert.enabled
  auto_mitigate = each.value.metric_alert.auto_mitigate
  frequency = each.value.metric_alert.frequency
  severity = each.value.metric_alert.severity
  target_resource_type = each.value.metric_alert.target_resource_type
  target_resource_location = each.value.metric_alert.target_resource_location
  window_size = each.value.metric_alert.window_size

  action {
    action_group_id = var.ag[each.value.metric_alert.action_group].id
  }

  criteria {
    metric_namespace = each.value.metric_alert.criteria.metric_namespace
    metric_name      = each.value.metric_alert.criteria.metric_name
    aggregation      = each.value.metric_alert.criteria.aggregation
    operator         = each.value.metric_alert.criteria.operator
    threshold        = each.value.metric_alert.criteria.threshold
    
    /*
    dimension {
      name     = each.value.metric_alert.criteria.dimension.name
      operator = each.value.metric_alert.criteria.dimension.operator
      values   = [each.value.metric_alert.criteria.dimension.values]
    }
    */
    skip_metric_validation = each.value.metric_alert.criteria.skip_metric_validation
  }
  /*
  dynamic_criteria {
    #for_each = each.value.metric_alert.dynamic_criteria == null ? [] : [1]

    metric_namespace = each.value.metric_alert.dynamic_criteria.metric_namespace
    metric_name      = each.value.metric_alert.dynamic_criteria.metric_name
    aggregation      = each.value.metric_alert.dynamic_criteria.aggregation
    operator         = each.value.metric_alert.dynamic_criteria.operator
    alert_sensitivity        = each.value.metric_alert.dynamic_criteria.alert_sensitivity
    dimension {
      name     = each.value.metric_alert.dynamic_criteria.dimension.name
      operator = each.value.metric_alert.dynamic_criteria.dimension.operator
      values   = [each.value.metric_alert.dynamic_criteria.dimension.values]
    }
    evaluation_total_count = each.value.metric_alert.dynamic_criteria.evaluation_total_count
    evaluation_failure_count = each.value.metric_alert.dynamic_criteria.evaluation_failure_count
    ignore_data_before = each.value.metric_alert.dynamic_criteria.ignore_data_before
    skip_metric_validation = each.value.metric_alert.dynamic_criteria.skip_metric_validation
  }
  application_insights_web_test_location_availability_criteria {
    web_test_id = each.value.metric_alert.application_insights_web_test_location_availability_criteria.web_test_id
    component_id = each.value.metric_alert.application_insights_web_test_location_availability_criteria.component_id
    failed_location_count = each.value.metric_alert.application_insights_web_test_location_availability_criteria.failed_location_count
  }
 */ 
}