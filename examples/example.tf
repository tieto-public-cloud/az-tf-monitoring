terraform {
  experiments = [module_variable_optional_attrs]
  backend "azurerm" {
    resource_group_name  = "dubradan_monitoring_dev_westeurope_rg"
    storage_account_name = "dubradantestmonitoring"
    container_name       = "tfstate"
    key                  = "tpcpoc.tfstate"
  }
}
module "monitoring-alert" {
  source = "./.."

  monitor_default = {
    action_groups = {
      "tm_critical_action_group" = {
        short_name = "tm_crit_ag"
        email = {
          name          = "Email Tieto Default"
          email_address = "tietomanagedazurealerts@tieto.com"
        }
        webhook = {
          name        = "ServiceNow"
          service_uri = "https://Event_Management_Azure:KSRQYCYkWY4wKm2uSA@tieto.service-now.com/api/global/em/inbound_event?source=AzureLogAnalyticsEvent"
        }
      }
      "tm_warning_action_group" = {
        short_name = "tm_crit_ag"
        email = {
          name          = "Email Tieto Default"
          email_address = "tietomanagedazurealerts@tieto.com"
        }
        webhook = {
          name        = "ServiceNow"
          service_uri = "https://Event_Management_Azure:KSRQYCYkWY4wKm2uSA@tieto.service-now.com/api/global/em/inbound_event?source=AzureLogAnalyticsEvent"
        }
      }
    }

    query_alerts  = local.query_alert
    metric_alerts = local.metric_alert

  }

}