param($ResourceGroupName)
$Alerts = Get-AzScheduledQueryRule -ResourceGroupName $ResourceGroupName
$Data = New-Object System.Collections.ArrayList
foreach ($Alert in $Alerts) {
    $Source = $Alert | Select-Object -ExpandProperty Source
    $Schedule = $Alert | Select-Object -ExpandProperty Schedule
    $Action  = $Alert | Select-Object -ExpandProperty Action
    $AG = $Action | Select-Object -ExpandProperty AznsAction
    $Trigger = $Action | Select-Object -ExpandProperty Trigger
    $MetricTrigger = $Trigger | Select-Object -ExpandProperty MetricTrigger

        $Data.Add([PSCustomObject]@{

            Name = $Alert.Name
            Severity = $Action.Severity
            Description = $Alert.Description
            Query = $Source.Query
            QueryType = $Source.QueryType
            ThresholdOperator = $Trigger.ThresholdOperator
            Threshold = $Trigger.Threshold
            FrequencyInMinutes = $Schedule.FrequencyInMinutes
            TimeWindowInMinutes = $Schedule.TimeWindowInMinutes
            MTThresholdOperator = $MetricTrigger.ThresholdOperator
            MTThreshold = $MetricTrigger.Threshold
            MTMetricTriggerType = $MetricTrigger.MetricTriggerType
            MTMetricColumn = $MetricTrigger.MetricColumn
            AG = $AG.ActionGroup[0]
        })
    }

$Data | Sort-Object -Property Name | convertto-csv -Delimiter ";"| out-file ./alerts-${ResourceGroupName}.csv
