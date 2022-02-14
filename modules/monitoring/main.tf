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
  for_each = toset(local.action_groups) # See variables_action_groups.tf for locals.

  name                = each.value.name
  resource_group_name = var.law_resource_group_name
  short_name          = each.value.short_name

  dynamic "webhook_receiver" {
    for_each = each.value.webhook == null ? [] : [1]

    content {
      name                    = each.value.webhook.name
      service_uri             = each.value.webhook.service_uri
      use_common_alert_schema = each.value.webhook.use_common_alert_schema
    }
  }

  dynamic "email_receiver" {
    for_each = each.value.email == null ? [] : [1]

    content {
      name                    = each.value.email.name
      email_address           = each.value.email.email_address
      use_common_alert_schema = each.value.email.use_common_alert_schema
    }
  }

  dynamic "arm_role_receiver" {
    for_each = each.value.arm_role_receiver == null ? [] : [1]

    content {
      name                    = each.value.arm_role_receiver.name
      role_id                 = each.value.arm_role_receiver.role_id
      use_common_alert_schema = each.value.arm_role_receiver.use_common_alert_schema
    }
  }

  # Attach common tags passed from the caller.
  tags = var.common_tags

  # This could take a long time, extend default timeouts.
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

##############################################################################
## Log Query Alerts
##############################################################################

resource "azurerm_monitor_scheduled_query_rules_alert" "query_alert" {
  for_each = toset(local.deploy_log_signals)

  resource_group_name = var.law_resource_group_name
  location            = var.location
  data_source_id      = data.azurerm_log_analytics_workspace.law.id

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
      azurerm_monitor_action_group.action_group[index(azurerm_monitor_action_group.action_group.*.name, each.value.action_group)].id
    ]
  }

  # This could take a long time, extend default timeouts.
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

##############################################################################
## Metric Alerts
##############################################################################

resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each = toset(var.metric_signals)

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
    action_group_id = azurerm_monitor_action_group.action_group[index(azurerm_monitor_action_group.action_group.*.name, each.value.action_group)].id
  }

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold

    dynamic "dimension" {
      for_each = each.value.criteria.dimension == null ? [] : [1]

      content {
        name     = each.value.criteria.dimension.name
        operator = each.value.criteria.dimension.operator
        values   = each.value.criteria.dimension.values
      }
    }

    skip_metric_validation = each.value.criteria.skip_metric_validation
  }

  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria == null ? [] : [1]

    content {
      metric_namespace  = each.value.dynamic_criteria.metric_namespace
      metric_name       = each.value.dynamic_criteria.metric_name
      aggregation       = each.value.dynamic_criteria.aggregation
      operator          = each.value.dynamic_criteria.operator
      alert_sensitivity = each.value.dynamic_criteria.alert_sensitivity

      dynamic "dimension" {
        for_each = each.value.dynamic_criteria.dimension == null ? [] : [1]

        content {
          name     = each.value.dynamic_criteria.dimension.name
          operator = each.value.dynamic_criteria.dimension.operator
          values   = each.value.dynamic_criteria.dimension.values
        }
      }

      evaluation_total_count = each.value.dynamic_criteria.evaluation_total_count
      evaluation_failure_count = each.value.dynamic_criteria.evaluation_failure_count
      ignore_data_before = each.value.dynamic_criteria.ignore_data_before
      skip_metric_validation = each.value.dynamic_criteria.skip_metric_validation
    }
  }

  dynamic "application_insights_web_test_location_availability_criteria" {
    for_each = each.value.application_insights_web_test_location_availability_criteria == null ? [] : [1]

    content {
      web_test_id = each.value.application_insights_web_test_location_availability_criteria.web_test_id
      component_id = each.value.application_insights_web_test_location_availability_criteria.component_id
      failed_location_count = each.value.application_insights_web_test_location_availability_criteria.failed_location_count
    }
  }

  # This could take a long time, extend default timeouts.
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
