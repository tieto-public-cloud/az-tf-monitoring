variable "deploy_monitoring_backup" {
  description = "Whether to deploy Monitoring alerts related to Backups"
  type        = bool
  default     = false
}

locals {
  backup_query = merge(var.backup_query, var.backup_custom_query)
}

variable "backup_query" {
  description = "Backups Monitor config for query based monitoring"
  default = {
    "Backups-JobStatus-Critical" = {
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
    }
    "Backups-JobStatus-Warning" = {
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
  }
  type = map(
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

variable "backup_custom_query" {
  description = "Azure Backup Monitor config for query based monitoring - custom"
  default     = null
  type = map(
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