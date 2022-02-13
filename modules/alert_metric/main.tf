# Deploy all Azure Monitor metric based alert rules.
resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each = var.deploy ? toset(var.metric_alerts) : toset([])

  name                     = each.value.name
  resource_group_name      = var.law_resource_group_name
  scopes                   = each.value.scopes
  description              = each.value.description
  enabled                  = each.value.enabled
  auto_mitigate            = each.value.auto_mitigate
  frequency                = each.value.frequency
  severity                 = each.value.severity
  target_resource_type     = each.value.target_resource_type
  target_resource_location = each.value.target_resource_location
  window_size              = each.value.window_size

  action {
    action_group_id = var.action_groups[index(var.action_groups.*.name, each.value.action_group)].id
  }

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold

    dynamic "dimension" {
      for_each = each.value.criteria.dimension == null ? [] : [1]

      name     = each.value.criteria.dimension.name
      operator = each.value.criteria.dimension.operator
      values   = each.value.criteria.dimension.values
    }

    skip_metric_validation = each.value.criteria.skip_metric_validation
  }

  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria == null ? [] : [1]

    metric_namespace  = each.value.dynamic_criteria.metric_namespace
    metric_name       = each.value.dynamic_criteria.metric_name
    aggregation       = each.value.dynamic_criteria.aggregation
    operator          = each.value.dynamic_criteria.operator
    alert_sensitivity = each.value.dynamic_criteria.alert_sensitivity

    dynamic "dimension" {
      for_each = each.value.dynamic_criteria.dimension == null ? [] : [1]

      name     = each.value.dynamic_criteria.dimension.name
      operator = each.value.dynamic_criteria.dimension.operator
      values   = each.value.dynamic_criteria.dimension.values
    }

    evaluation_total_count = each.value.dynamic_criteria.evaluation_total_count
    evaluation_failure_count = each.value.dynamic_criteria.evaluation_failure_count
    ignore_data_before = each.value.dynamic_criteria.ignore_data_before
    skip_metric_validation = each.value.dynamic_criteria.skip_metric_validation
  }

  dynamic "application_insights_web_test_location_availability_criteria" {
    for_each = each.value.application_insights_web_test_location_availability_criteria == null ? [] : [1]

    web_test_id = each.value.application_insights_web_test_location_availability_criteria.web_test_id
    component_id = each.value.application_insights_web_test_location_availability_criteria.component_id
    failed_location_count = each.value.application_insights_web_test_location_availability_criteria.failed_location_count
  }
}
