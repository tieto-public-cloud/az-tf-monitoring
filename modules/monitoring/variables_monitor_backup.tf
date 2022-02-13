variable "monitor_backup" {
  description = "Deploy monitoring for Azure Backups"
  type        = bool
  default     = false
}

variable "backup_log_signals" {
  description = "Azure Backup Monitor config for query based monitoring - custom"
  default     = []
  type = list(
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
}

locals {
  backup_log_signals_default = [
    {
      name         = "Backups - Job Status - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AddonAzureBackupJobs | where JobStatus == 'Failed' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s"
      severity     = 0
      frequency    = 60
      time_window  = 60
      action_group = "tm-critical-actiongroup"

      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    },
    {
      name         = "Backups - Job Status - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = AddonAzureBackupJobs | where JobStatus == 'CompletedWithWarnings' ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s"
      severity     = 1
      frequency    = 60
      time_window  = 60
      action_group = "tm-warning-actiongroup"

      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    }
  ]

  backup_log_signals = concat(local.backup_log_signals_default, var.backup_log_signals)
}
