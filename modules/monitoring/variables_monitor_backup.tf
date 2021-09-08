#
# Azure Monitor action group configurations
#

# Template for easy creation with Mustache https://mustache.github.io/
# Using following variables
variable "deploy_monitoring_backup" {
  description = "Whether to deploy Monitoring alerts related to Backups"
  type        = bool
  default     = false
}

variable "backup-query" {
  description = "Backups Monitor Config for Query based monitoring"
  default = {
    query_alert_default = {
      "Backups-JobStatus-Critical" = {
        name         = "Backups - Job Status - Critical"
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AddonAzureBackupJobs | where JobStatus == 'Failed' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s"
        severity     = 0
        frequency    = 60
        time_window  = 60
        action_group = "tm_critical_action_group"
        trigger = {
          operator  = "GreaterThan"
          threshold = 0
        }
      }
      "Backups-JobStatus-Warning" = {
        name         = "Backups - Job Status - Warning"
        query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AddonAzureBackupJobs | where JobStatus == 'CompletedWithWarnings' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s"
        severity     = 1
        frequency    = 60
        time_window  = 60
        action_group = "tm_warning_action_group"
        trigger = {
          operator  = "GreaterThan"
          threshold = 0
        }
      }
    }
  }
  type = object({
    query_alert_default = map(
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
  })
}