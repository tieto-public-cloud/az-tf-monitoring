##############################################################################
## Creates common monitoring set up - action groups - and delegates the
## rest to other modules.
##
## Delegated:
## * Creation of log query based alerts to alert_query.
## * Creation of metric based alerts to metric_query.
## * Creation of a Function App pushing resource tags to LAW to tagging_functionapp.
##
##############################################################################

locals {
  # All available bundles have to be explicitly registered here.
  all_log_signals = {
    azurevm             = local.azurevm_log_signals
    azuresql            = local.azuresql_log_signals
    backup              = local.backup_log_signals
    agw                 = local.agw_log_signals
    azurefunction       = local.azurefunction_log_signals
    datafactory         = local.datafactory_log_signals
    expressroute        = local.expressroute_log_signals
    lb                  = local.lb_log_signals
    tagging_functionapp = local.tagging_functionapp_log_signals
  }

  # Only selected bundles will be applied. The caller is selecting.
  deploy_log_signals = flatten([for ksig, vsig in local.all_log_signals : vsig if contains(var.monitor, ksig) ])
}

# Get information about our target LAW.
data "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  resource_group_name = var.law_resource_group_name
}

##############################################################################
## Action Groups for Alerts
##############################################################################

# For Azure Monitor action groups, currently only webhook, email and ARM receivers
# are supported but other receivers can be added to the code easily following
# the existing pattern.
resource "azurerm_monitor_action_group" "action_group" {
  for_each = { for ag in local.action_groups : ag.name => ag } # See variables_action_groups.tf for locals.

  name                = each.value.name
  resource_group_name = var.law_resource_group_name
  short_name          = each.value.short_name

  dynamic "webhook_receiver" {
    for_each = lookup(each.value, "webhook", null) == null ? [] : [1]

    content {
      name                    = each.value.webhook.name
      service_uri             = each.value.webhook.service_uri
      use_common_alert_schema = each.value.webhook.use_common_alert_schema
    }
  }

  dynamic "email_receiver" {
    for_each = lookup(each.value, "email", null) == null ? [] : [1]

    content {
      name                    = each.value.email.name
      email_address           = each.value.email.email_address
      use_common_alert_schema = each.value.email.use_common_alert_schema
    }
  }

  dynamic "arm_role_receiver" {
    for_each = lookup(each.value, "arm_role_receiver", null) == null ? [] : [1]

    content {
      name                    = each.value.arm_role_receiver.name
      role_id                 = each.value.arm_role_receiver.role_id
      use_common_alert_schema = each.value.arm_role_receiver.use_common_alert_schema
    }
  }

  dynamic "logic_app_receiver" {
    for_each = lookup(each.value, "logic_app_receiver", null) == null ? [] : [1]

    content {
      name                    = each.value.logic_app_receiver.name
      resource_id             = each.value.logic_app_receiver.resource_id
      callback_url            = each.value.logic_app_receiver.callback_url
      use_common_alert_schema = each.value.logic_app_receiver.use_common_alert_schema
    }
  }

  dynamic "azure_function_receiver" {
    for_each = lookup(each.value, "azure_function_receiver", null) == null ? [] : [1]

    content {
      name                     = each.value.azure_function_receiver.name
      function_app_resource_id = each.value.azure_function_receiver.function_app_resource_id
      function_name            = each.value.azure_function_receiver.function_name
      http_trigger_url         = each.value.azure_function_receiver.http_trigger_url
      use_common_alert_schema  = each.value.azure_function_receiver.use_common_alert_schema
    }
  }

  # Attach common tags passed from the caller.
  tags = var.common_tags
}

##############################################################################
## Log Query Alerts
##############################################################################

resource "azurerm_monitor_scheduled_query_rules_alert" "query_alert" {
  for_each = { for dls in local.deploy_log_signals : dls.name => dls }

  resource_group_name = var.law_resource_group_name
  location            = var.location
  data_source_id      = data.azurerm_log_analytics_workspace.law.id

  name        = each.value.name
  description = each.value.name
  frequency   = each.value.frequency
  query       = each.value.query
  time_window = each.value.time_window
  enabled     = lookup(each.value, "enabled", null)
  severity    = lookup(each.value, "severity", null)
  throttling  = lookup(each.value, "throttling", null)

  trigger {
    operator  = each.value.trigger.operator
    threshold = each.value.trigger.threshold

    dynamic "metric_trigger" {
      for_each = lookup(each.value.trigger, "metric_trigger", null) == null ? [] : [1]

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
      azurerm_monitor_action_group.action_group[each.value.action_group].id
    ]
  }
}

##############################################################################
## Metric Alerts
##############################################################################

resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each = { for ms in var.metric_signals : ms.name => ms }

  name                     = each.value.name
  resource_group_name      = var.law_resource_group_name
  scopes                   = each.value.scopes
  description              = lookup(each.value, "description", null)
  enabled                  = lookup(each.value, "enabled", null)
  auto_mitigate            = lookup(each.value, "auto_mitigate", null)
  frequency                = lookup(each.value, "frequency", null)
  severity                 = lookup(each.value, "severity", null)
  target_resource_type     = lookup(each.value, "target_resource_type", null)
  target_resource_location = lookup(each.value, "target_resource_location", null)
  window_size              = lookup(each.value, "window_size", null)

  action {
    action_group_id = azurerm_monitor_action_group.action_group[each.value.action_group].id
  }

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold

    dynamic "dimension" {
      for_each = lookup(each.value.criteria, "dimension", null) == null ? [] : [1]

      content {
        name     = each.value.criteria.dimension.name
        operator = each.value.criteria.dimension.operator
        values   = each.value.criteria.dimension.values
      }
    }

    skip_metric_validation = lookup(each.value.criteria, "skip_metric_validation", null)
  }

  dynamic "dynamic_criteria" {
    for_each = lookup(each.value, "dynamic_criteria", null) == null ? [] : [1]

    content {
      metric_namespace  = each.value.dynamic_criteria.metric_namespace
      metric_name       = each.value.dynamic_criteria.metric_name
      aggregation       = each.value.dynamic_criteria.aggregation
      operator          = each.value.dynamic_criteria.operator
      alert_sensitivity = each.value.dynamic_criteria.alert_sensitivity

      dynamic "dimension" {
        for_each = lookup(each.value.dynamic_criteria, "dimension", null) == null ? [] : [1]

        content {
          name     = each.value.dynamic_criteria.dimension.name
          operator = each.value.dynamic_criteria.dimension.operator
          values   = each.value.dynamic_criteria.dimension.values
        }
      }

      evaluation_total_count   = lookup(each.value.dynamic_criteria, "evaluation_total_count", null)
      evaluation_failure_count = lookup(each.value.dynamic_criteria, "evaluation_failure_count", null)
      ignore_data_before       = lookup(each.value.dynamic_criteria, "ignore_data_before", null)
      skip_metric_validation   = lookup(each.value.dynamic_criteria, "skip_metric_validation", null)
    }
  }

  dynamic "application_insights_web_test_location_availability_criteria" {
    for_each = lookup(each.value, "application_insights_web_test_location_availability_criteria", null) == null ? [] : [1]

    content {
      web_test_id = each.value.application_insights_web_test_location_availability_criteria.web_test_id
      component_id = each.value.application_insights_web_test_location_availability_criteria.component_id
      failed_location_count = each.value.application_insights_web_test_location_availability_criteria.failed_location_count
    }
  }

  # Attach common tags passed from the caller.
  tags = var.common_tags
}
