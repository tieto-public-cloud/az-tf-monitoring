# Deploy TE Azure Monitoring via Terraform

## General thoughts and expectations

- We should be able to deploy monitoring only for needed resource types
- By default we use log workspace and query alerts types on that log workspace
- We should be able to create custom alerts (even the metric ones for custom alerts should be possible)
- Metric alerts should be able to be scoped and not expect to use all available subscriptions for deployment

## Monitoring modules usage

The TF code calls root module in ./modules/monitoring to deploy following resources:
- If needed - Resource group and Log Analytics Workspace
- Action groups
- Calls child module at ./modules/alerts for each monitoring alert bundle that is supposed to be deployed

### Module "monitoring"

### New resource type alert template

Template for easy creation with Mustache https://mustache.github.io/
Using following variables

SHORTNAME - shor resource type name used in TF resource / variable naming, must not contain any spaces nor underscores and all letters must be lowcase (eg azurevm, azuresql) 
RESOURCE_TYPE - 
METRIC

variable "deploy_monitoring_{{SHORTNAME}}" {
  description = "Whether to deploy Monitoring alerts related to {{RESOURCE_TYPE}}"
  type        = bool
  default     = false
}

variable "{{SHORTNAME}}-query" {
  description = "{{RESOURCE_TYPE}} Monitor Config for Query based monitoring"
  default = {
    query_alert_default = {
      "{{RESOURCE_TYPE}}-{{METRIC_NOSPACE}}-Critical" = {
        name         = "{{RESOURCE_TYPE}} - {{METRIC}} - Critical"
        query        = ""
        severity     = 0
        frequency    = 15
        time_window  = 30
        action_group = "tm_critical_action_group"
        trigger = {
          operator  = "GreaterThan"
          threshold = 2
          metric_trigger = {
            operator  = "GreaterThan"
            threshold = 0
            type      = "Consecutive"
            column    = "Resource"
          }
        }