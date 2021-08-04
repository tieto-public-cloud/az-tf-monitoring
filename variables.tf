# A typical setup for most configuration options is that they are used as local.variable_name in
# the code and the local variable is built by mergig pre-defined variable_name_default default
# configuration and configurable variable_name_local.  This _local variable can be used to
# override any defaults in the templates.

locals {
  monitor = merge(var.monitor_default, var.monitor_local)
}
variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}
variable "log_analytics_workspace_resource_group" {
  type        = string
  description = "The log Analytics Workspace resource group name"
  default     = "rds-use-dev-rg"
}
variable "create_log_analytics_workspace" {
  description = "Whether to create log analytics workspace and use it for all monitoring resources"
  default     = false
}
variable "log_analytics_workspace_name" {
  type        = string
  description = "The log Analytics Workspace Name"
  default     = "nik-rds-weu-dev-sol"
}

variable "location" {
  description = "The location/region to keep all your monitoring resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}
variable "monitor_local" {
  #
  # Local Azure Log Analytics and Azure Monitor configuration
  #
  description = "Local Azure Log Analytics and Azure Monitor configuration"
  default     = null
}
variable "monitor_default" {
  #
  # Default Azure Log Analytics and Azure Monitor configuration
  #
  description = "Default Azure Log Analytics and Azure Monitor configuration"
  type = object({
    #
    # Azure Monitor action group configurations
    #
    action_groups = map(
      object({
        short_name = optional(string)
        email = optional(object({
          name                    = string
          email_address           = string
          use_common_alert_schema = optional(bool)
        }))
        webhook = optional(object({
          name                    = string
          service_uri             = string
          use_common_alert_schema = optional(bool)
        }))
        arm_role_receiver = optional(object({
          name                    = string
          role_id                 = string
          use_common_alert_schema = optional(bool)
        }))
        automation_runbook_receiver = optional(object({
          name                    = string
          automation_account_id   = string
          runbook_name            = string
          webhook_resource_id     = string
          is_global_runbook       = string
          service_uri             = string
          use_common_alert_schema = optional(bool)
        }))
        azure_app_push_receiver = optional(object({
          name          = string
          email_address = string
        }))
        azure_function_receiver = optional(object({
          name                     = string
          function_app_resource_id = string
          function_name            = string
          http_trigger_url         = string
          use_common_alert_schema  = optional(bool)
        }))
        itsm_receiver = optional(object({
          name                 = string
          workspace_id         = string
          connection_id        = string
          ticket_configuration = string
          region               = string
        }))
        logic_app_receiver = optional(object({
          name                    = string
          resource_id             = string
          callback_url            = string
          use_common_alert_schema = optional(bool)
        }))
        sms_receiver = optional(object({
          name         = string
          country_code = string
          phone_number = string
        }))
      })
    )

    #
    # Azure Monitor query-based alert configurations
    #

    query_alerts = map(
      object({
        name         = string
        enabled      = optional(bool)
        query        = string
        severity     = optional(number)
        frequency    = number
        time_window  = number
        action_group = string
        throttling   = optional(number)
        trigger = object({
          operator  = string
          threshold = number
          metric_trigger = optional(object({
            operator  = string
            threshold = string
            type      = string
            column    = string
          }))
        })
      })
    )

    #
    # Azure Monitor metric based alert configurations
    #

    metric_alerts = map(
      object({
        enabled = optional(bool)
        auto_mitigate = optional(bool)
        description = optional(string)
        frequency = optional(string)
        severity = optional(number)
        target_resource_type = optional(string)
        target_resource_location = optional(string)
        window_size = optional(string)
        action_group = string
        criteria = optional(object({
          metric_namespace = string
          metric_name      = string
          aggregation      = string
          operator         = string
          threshold        = number
          dimension = optional(object({
            name     = string
            operator = string
            values   = list(string)
          }))
          skip_metric_validation = optional(bool)
        }))
        dynamic_criteria = optional(object({
          metric_namespace  = string
          metric_name       = string
          aggregation       = string
          operator          = string
          alert_sensitivity = string
          dimension = optional(object({
            name     = string
            operator = string
            values   = list(string)
          }))
          evaluation_total_count   = optional(number)
          evaluation_failure_count = optional(number)
          ignore_data_before        = optional(string)
          skip_metric_validation   = optional(bool)
        }))
        application_insights_web_test_location_availability_criteria = optional(object({
          web_test_id           = string
          component_id         = string
          failed_location_count = number
        }))
      })
    )
  })

  /*default = {

    query_alerts = {
      "vm-cpu-usage-critical" = {
        name         = "Azure VM - CPU Usage - Critical"
        query        = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
        severity     = 0
        frequency    = 5
        time_window  = 15
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 90
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 2
            type      = "Consecutive"
            column    = "Computer"
          }
        }
      }
      "vm-cpu-usage-warning" = {
        name         = "Azure VM - CPU Usage - Warning"
        query        = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
        severity     = 1
        frequency    = 5
        time_window  = 15
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 80
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 2
            type      = "Consecutive"
            column    = "Computer"
          }
        }
      }
      #
      "vm-mem-usage-critical" = {
        name         = "Azure VM - Memory Usage - Critical"
        query        = "Perf | where ObjectName == 'Memory' and (CounterName == '% Committed Bytes In Use' or CounterName == '% Used Memory') | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
        severity     = 0
        frequency    = 5
        time_window  = 15
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 90
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 1
            type      = "Consecutive"
            column    = "Computer"
          }
        }
      }
      "vm-mem-usage-warning" = {
        name         = "Azure VM - Memory Usage - Warning"
        query        = "Perf | where ObjectName == 'Memory' and (CounterName == '% Committed Bytes In Use' or CounterName == '% Used Memory') | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer"
        severity     = 1
        frequency    = 5
        time_window  = 15
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 80
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 1
            type      = "Consecutive"
            column    = "Computer"
          }
        }
      }
      #
      "vm-os-disk-free-space-critical" = {
        name         = "Azure VM - OS Disk Free Space - Critical"
        query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 0
        frequency    = 30
        time_window  = 30
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "LessThan"
          threshold = 10
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      "vm-os-disk-free-space-warning" = {
        name         = "Azure VM - OS Disk Free Space - Warning"
        query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 1
        frequency    = 30
        time_window  = 30
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "LessThan"
          threshold = 20
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      #
      "vm-data-disk-free-space-critical" = {
        name         = "Azure VM - Data Disk Free Space - Critical"
        query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 0
        frequency    = 30
        time_window  = 30
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "LessThan"
          threshold = 15
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      "vm-data-disk-free-space-warning" = {
        name         = "Azure VM - Data Disk Free Space - Warning"
        query        = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 1
        frequency    = 30
        time_window  = 30
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "LessThan"
          threshold = 25
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      #
      "vm-disk-free-space-critical" = {
        name         = "Azure VM - Disk Used Space - Critical"
        query        = "Perf | where ObjectName == 'Logical Disk' and CounterName == '% Used Space' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 0
        frequency    = 30
        time_window  = 30
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 90
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      "vm-disk-free-space-warning" = {
        name         = "Azure VM - Disk Used Space - Warning"
        query        = "Perf | where ObjectName == 'Logical Disk' and CounterName == '% Used Space' | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName"
        severity     = 1
        frequency    = 30
        time_window  = 30
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 80
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Total"
            column    = "Computer"
          }
        }
      }
      # Add others
      "vm-agent-unreachable-critical" = {
        name         = "Azure VM - Agent Unreachable - Critical"
        query        = "Heartbeat | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
        severity     = 0
        frequency    = 5
        time_window  = 60
        action_group = "saptm-critical-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 0
        }
      }
      "vm-agent-unreachable-warning" = {
        name         = "Azure VM - Agent Unreachable - Warning"
        query        = "Heartbeat | summarize LastCall = max(TimeGenerated) by Computer | where LastCall < ago(20m)"
        severity     = 1
        frequency    = 5
        time_window  = 60
        action_group = "saptm-warning-actiongroup"
        trigger = {
          operator  = "GreaterThan"
          threshold = 0
        }
      }

    }
  }*/
}
