#
# Azure Monitor action group configurations
#
variable "deploy_monitoring_azurevm" {
  description = "Whether to deploy Monitoring alerts related to Azure VM"
  type        = bool
  default     = false
}

locals {
  azurevm_query = merge(var.azurevm_query, var.azurevm_custom_query)
}

variable "azurevm_query" {
  description = "Azure VM Monitor config for query based monitoring"
  default = {
    # Default cpu alert baseline
    "AzureVM-CPUUsage-Critical" = {
      name         = "Azure VM - CPU Usage - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_cpu\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    "AzureVM-CPUUsage-Warning" = {
      name         = "Azure VM - CPU Usage - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_cpu\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    # High CPU alert baseline
    "AzureVM-CPUUsageHigh-Critical" = {
      name         = "Azure VM - CPU Usage High - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_cpu\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    "AzureVM-CPUUsageHigh-Warning" = {
      name         = "Azure VM - CPU Usage High - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_cpu\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    # Slow CPU alert baseline
    "AzureVM-CPUUsageSlow-Critical" = {
      name         = "Azure VM - CPU Usage Slow - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_cpu\": \"slow\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    "AzureVM-CPUUsageSlow-Warning" = {
      name         = "Azure VM - CPU Usage Slow - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_cpu\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Processor' and CounterName == '% Processor Time'; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id), _SubscriptionId"
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
    }
    # Default Memory alert baseline
    "AzureVM-MemoryUsage-Critical" = {
      name         = "Azure VM - Memory Usage - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_mem\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-MemoryUsage-Warning" = {
      name         = "Azure VM - Memory Usage - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_mem\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # High Memory alert baseline
    "AzureVM-MemoryUsageHigh-Critical" = {
      name         = "Azure VM - Memory Usage High - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_mem\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-MemoryUsageHigh-Warning" = {
      name         = "Azure VM - Memory Usage High - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_mem\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # Slow Memory alert baseline
    "AzureVM-MemoryUsageSlow-Critical" = {
      name         = "Azure VM - Memory Usage Slow - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_mem\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-MemoryUsageSlow-Warning" = {
      name         = "Azure VM - Memory Usage Slow - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_mem\": \"slow\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s); let _perf = InsightsMetrics| where Namespace == 'Memory' and Name == 'AvailableMB' | extend tags = todynamic(Tags) | project TimeGenerated, _ResourceId, Computer, P = round(100 - ((Val / parse_json(tags['vm.azm.ms/memorySizeMB'])) * 100)), _SubscriptionId  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s  | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(P) by bin(TimeGenerated, 5m), Computer, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # Default Windows OS Disk alert baseline
    "AzureVM-WinOSDiskFreeSpace-Critical" = {
      name         = "Azure VM - Win OS Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_wosdisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinOSDiskFreeSpace-Warning" = {
      name         = "Azure VM - Win OS Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_wosdisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # High Windows OS Disk alert baseline
    "AzureVM-WinOSDiskFreeSpaceHigh-Critical" = {
      name         = "Azure VM - Win OS Disk High Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wosdisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinOSDiskFreeSpaceHigh-Warning" = {
      name         = "Azure VM - Win OS Disk High Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wosdisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # Highest Windows OS Disk alert baseline
    "AzureVM-WinOSDiskFreeSpaceHighest-Critical" = {
      name         = "Azure VM - Win OS Disk Highest Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wosdisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinOSDiskFreeSpaceHighest-Warning" = {
      name         = "Azure VM - Win OS Disk Highest Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wosdisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName == 'C:'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id),  SubscriptionId = _SubscriptionId"
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
    }
    # Default Windows Data disk alert baseline
    "AzureVM-WinDataDiskFreeSpace-Critical" = {
      name         = "Azure VM - Win Data Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_wdatadisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinDataDiskFreeSpace-Warning" = {
      name         = "Azure VM - Win Data Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_wdatadisk\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # High Windows Data disk alert baseline
    "AzureVM-WinDataDiskFreeSpaceHigh-Critical" = {
      name         = "Azure VM - Win Data High Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wdatadisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinDataDiskFreeSpaceHigh-Warning" = {
      name         = "Azure VM - Win Data High Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wdatadisk\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # Highest Windows Data disk alert baseline
    "AzureVM-WinDataDiskFreeSpaceHighest-Critical" = {
      name         = "Azure VM - Win Data Highest Disk Free Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wdatadisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-WinDataDiskFreeSpaceHighest-Warning" = {
      name         = "Azure VM - Win Data Highest Disk Free Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_wdatadisk\": \"highest\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' and InstanceName != 'C:' and InstanceName != '_Total' and InstanceName notcontains 'Harddisk'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # Default Linux disk alert baseline
    "AzureVM-LinuxDiskUsedSpace-Critical" = {
      name         = "Azure VM - Linux Disk Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_ldisk\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-LinuxDiskUsedSpace-Warning" = {
      name         = "Azure VM - Linux Disk Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s !contains '\"monitoring_ldisk\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # High Linux disk alert baseline
    "AzureVM-LinuxDiskUsedSpaceHigh-Critical" = {
      name         = "Azure VM - Linux Disk High Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_ldisk\": \"high\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-LinuxDiskUsedSpaceHigh-Warning" = {
      name         = "Azure VM - Linux Disk High Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_ldisk\": \"high\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # Highest Linux disk alert baseline
    "AzureVM-LinuxDiskUsedSpaceHighest-Critical" = {
      name         = "Azure VM - Linux Disk Highest Used Space - Critical"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_ldisk\": \"highest\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    "AzureVM-LinuxDiskUsedSpaceHighest-Warning" = {
      name         = "Azure VM - Linux Disk Highest Used Space - Warning"
      query        = "let _resources = TagData_CL| where (Tags_s contains '\"te-managed-service\": \"workload\"' or Tags_s contains '\"te-managed-service\": \"true\"') and Tags_s contains '\"monitoring_ldisk\": \"highest\"' | summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Perf| where ObjectName == 'Logical Disk' and CounterName == '% Used Space'  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 30m), Computer, InstanceName, tostring(CMDB_Id), SubscriptionId = _SubscriptionId"
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
    }
    # Default Heartbeat alert baseline
    "AzureVM-AgentUnreachable-Critical" = {
      name         = "Azure VM - Agent Unreachable - Critical"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize LastCall = max(TimeGenerated) by Computer, tostring(CMDB_Id), SubscriptionId = _SubscriptionId | where LastCall < ago(20m)"
      severity     = 0
      frequency    = 5
      time_window  = 60
      action_group = "tm-critical-actiongroup"
      trigger = {
        operator  = "GreaterThan"
        threshold = 0
      }
    }
    "AzureVM-AgentUnreachable-Warning" = {
      name         = "Azure VM - Agent Unreachable - Warning"
      query        = "let _resources = TagData_CL| where Tags_s contains '\"te-managed-service\": \"workload\"'| summarize arg_max(TimeGenerated, *) by Id_s = tolower(Id_s);let _perf = Heartbeat  ; _perf| join kind=inner _resources on $left._ResourceId == $right.Id_s | extend d=parse_json(Tags_s) | extend CMDB_Id=d['te-cmdb-ci-id'] | summarize LastCall = max(TimeGenerated) by Computer, tostring(CMDB_Id), SubscriptionId = _SubscriptionId | where LastCall < ago(20m)"
      severity     = 1
      frequency    = 5
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

variable "azurevm_custom_query" {
  description = "Azure VM Monitor config for query based monitoring - custom"
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
