# For Azure Monitor action groups, currently only webhook and email receivers are supported but other receivers can
# be added to the code easily following the existing pattern.

# Build an array of all Azure Monitor action group deployments to each location.  A number of action groups can be 
# configured and they are configured to each location.
locals {
  monitor_action_group_deployments = [
    for n, p in var.action_groups : {
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
  resource_group_name = var.log_analytics_workspace_resource_group
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