# Azure Monitor

# For Azure Monitor action groups, currently only webhook and email receivers are supported but other receivers can
# be added to the code easily following the existing pattern.

# Local configuration - Default (required). 
locals {
  log_analytics_workspace_name = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.name, azurerm_log_analytics_workspace.law.*.name, [""]), 0)
  resource_group_name          = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  log_analytics_workspace_id   = element(coalescelist(data.azurerm_log_analytics_workspace.log_analytics_workspace.*.id, azurerm_log_analytics_workspace.law.*.id, [""]), 0)
}

# Datasources for Azure environment
# AzureRM provider client
data "azurerm_client_config" "current" {}

# Current Azure Subscription
data "azurerm_subscription" "current" {}

# All Azure Subscriptions
data "azurerm_subscriptions" "available" {}

# Resource Group Creation or selection - Default is "false"
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.log_analytics_workspace_resource_group
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.log_analytics_workspace_resource_group
  location = var.location
}

# Log Analytics Workspace Creation or selection - Default is "false"
data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  count               = var.create_log_analytics_workspace == false ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_log_analytics_workspace" "law" {
  count               = var.create_log_analytics_workspace == false ? 0 : 1
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
  location            = var.location
}

locals {
  # Build an array of all Azure Monitor action group deployments to each location.  A number of action groups can be 
  # configured and they are configured to each location.
  monitor_action_group_deployments = [
    for n, p in local.monitor.action_groups : {
      group_name = n
      group      = p
    }
  ]
}

resource "azurerm_monitor_action_group" "action_group" {
  # Deploy all Azure Monitor action groups.
  for_each = {
    for k in local.monitor_action_group_deployments : k.group_name => k
  }

  name                = each.value.group_name
  resource_group_name = local.resource_group_name
  short_name          = each.value.group.short_name != null ? each.value.group.short_name : length(each.value.group_name) > 12 ? substr(each.value.group_name, 0, 12) : each.value.group_name

  dynamic "webhook_receiver" {
    for_each = each.value.group.webhook == null ? [] : [1]

    content {
      name                    = each.value.group.webhook.name
      service_uri             = each.value.group.webhook.service_uri
      use_common_alert_schema = each.value.group.webhook.use_common_alert_schema
    }
  }

  dynamic "email_receiver" {
    for_each = each.value.group.email == null ? [] : [1]

    content {
      name                    = each.value.group.email.name
      email_address           = each.value.group.email.email_address
      use_common_alert_schema = each.value.group.email.use_common_alert_schema
    }
  }

  dynamic "arm_role_receiver" {
    for_each = each.value.group.arm_role_receiver == null ? [] : [1]

    content {
      name                    = each.value.group.arm_role_receiver.name
      role_id                 = each.value.group.arm_role_receiver.role_id
      use_common_alert_schema = each.value.group.arm_role_receiver.use_common_alert_schema
    }
  }
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

locals {
  # Build an array of all Azure Monitor query-based alert rules.  A number of rules can be configured and they are
  # configured to Azure Monitor in each location.
  monitor_query_alert_deployments = [
    for n, p in local.monitor.query_alerts : {
      query_alert_name = n
      query_alert      = p
    }
  ]
}

resource "azurerm_monitor_scheduled_query_rules_alert" "client" {
  # Deploy all Azure Monitor query-based alert rules.
  for_each = {
    for k in local.monitor_query_alert_deployments : k.query_alert_name => k
  }

  name                = each.value.query_alert.name
  resource_group_name = local.resource_group_name
  location            = var.location
  data_source_id      = local.log_analytics_workspace_id
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
      azurerm_monitor_action_group.action_group[each.value.query_alert.action_group].id
    ]
  }
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

locals {
  # Build an array of all Azure Monitor metric alert rules.  A number of rules can be configured and they are
  # configured to Azure Monitor.
  alert_list = flatten([
    for subscription in data.azurerm_subscriptions.available.subscriptions : [
      for alert_name, alert in local.monitor.metric_alerts :{
        metric_alert_name = alert_name
        metric_alert = alert
        subscription_id = subscription.id
      }
    ]
  ])
}

resource "azurerm_monitor_metric_alert" "metric_alerts" {
  # Deploy all Azure Monitor metric alert rules.
  for_each = {
    for k in local.alert_list : join("_", [k.metric_alert_name, k.subscription_id]) => k
  }

  name                = each.value.metric_alert_name
  resource_group_name = local.resource_group_name
  scopes              = [each.value.subscription_id]
  description         = each.value.metric_alert.description
  enabled = each.value.metric_alert.enabled
  auto_mitigate = each.value.metric_alert.auto_mitigate
  frequency = each.value.metric_alert.frequency
  severity = each.value.metric_alert.severity
  target_resource_type = each.value.metric_alert.target_resource_type
  target_resource_location = each.value.metric_alert.target_resource_location
  window_size = each.value.metric_alert.window_size

  action {
    action_group_id = azurerm_monitor_action_group.action_group[each.value.metric_alert.action_group].id
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