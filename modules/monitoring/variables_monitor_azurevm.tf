variable "azurevm_log_signals" {
  description = "Additional Azure VM configuration for query based monitoring to exetend the default configuration of the module"
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
  azurevm_log_singals_default = [
    # Default cpu alert baseline
    {
      name         = "Azure VM - CPU Usage - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-cpu\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 2
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - CPU Usage - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-cpu\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
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
    },
    # High CPU alert baseline
    {
      name         = "Azure VM - CPU Usage High - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-cpu\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 98
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 2
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - CPU Usage High - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-cpu\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 2
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    # Slow CPU alert baseline
    {
      name         = "Azure VM - CPU Usage Slow - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-cpu\": \"slow\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 90
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 6
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - CPU Usage Slow - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-cpu\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 80
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 6
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    # Default Memory alert baseline
    {
      name         = "Azure VM - Memory Usage - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-mem\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Memory Usage - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-mem\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 87
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    # High Memory alert baseline
    {
      name         = "Azure VM - Memory Usage High - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-mem\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 98
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Memory Usage High - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-mem\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 96
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 1
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    # Slow Memory alert baseline
    {
      name         = "Azure VM - Memory Usage Slow - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-mem\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 5
      time_window  = 15
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 6
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Memory Usage Slow - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-mem\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 5
      time_window  = 15
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 87
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 6
          type      = "Consecutive"
          column    = "Computer"
        }
      }
    },
    # Default Windows OS Disk alert baseline
    {
      name         = "Azure VM - Win OS Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-wosdisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
    },
    {
      name         = "Azure VM - Win OS Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-wosdisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # High Windows OS Disk alert baseline
    {
      name         = "Azure VM - Win OS Disk High Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wosdisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 5
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Win OS Disk High Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wosdisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # Highest Windows OS Disk alert baseline
    {
      name         = "Azure VM - Win OS Disk Highest Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wosdisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 7
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Win OS Disk Highest Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wosdisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 4
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    # Default Windows Data disk alert baseline
    {
      name         = "Azure VM - Win Data Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-wdatadisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
    },
    {
      name         = "Azure VM - Win Data Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-wdatadisk\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # High Windows Data disk alert baseline
    {
      name         = "Azure VM - Win Data High Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wdatadisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 5
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Win Data High Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wdatadisk\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # Highest Windows Data disk alert baseline
    {
      name         = "Azure VM - Win Data Highest Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wdatadisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 4
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Win Data Highest Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-wdatadisk\": \"highest\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "LessThan"
        threshold = 7
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    # Default Linux disk alert baseline
    {
      name         = "Azure VM - Linux Disk Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-ldisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
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
    },
    {
      name         = "Azure VM - Linux Disk Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring-ldisk\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # High Linux disk alert baseline
    {
      name         = "Azure VM - Linux Disk High Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-ldisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 95
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Linux Disk High Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-ldisk\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
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
    },
    # Highest Linux disk alert baseline
    {
      name         = "Azure VM - Linux Disk Highest Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-ldisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 0
      frequency    = 30
      time_window  = 30
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 97
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    {
      name         = "Azure VM - Linux Disk Highest Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring-ldisk\": \"highest\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
      severity     = 1
      frequency    = 30
      time_window  = 30
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 94
        metric_trigger = {
          operator  = "GreaterThan"
          threshold = 0
          type      = "Total"
          column    = "Computer"
        }
      }
    },
    # Default Heartbeat alert baseline
    {
      name         = "Azure VM - Agent Unreachable - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize LastCall = max(TimeGenerated) by Computer, tostring(CMDB_Id), SubscriptionId = _SubscriptionId | where LastCall < ago(20m)"
      severity     = 0
      frequency    = 5
      time_window  = 60
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    },
    {
      name         = "Azure VM - Agent Unreachable - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize LastCall = max(TimeGenerated) by Computer, tostring(CMDB_Id), SubscriptionId = _SubscriptionId | where LastCall < ago(10m)"
      severity     = 1
      frequency    = 5
      time_window  = 60
      action_group = "tm-warning-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    }
  ]

  azurevm_log_signals = concat(local.azurevm_log_singals_default, var.azurevm_log_signals)
}
