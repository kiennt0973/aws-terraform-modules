resource "aws_cloudwatch_log_group" "this" {
  for_each          = toset(var.log_group_names)
  name              = each.value
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = var.alarms
  alarm_name          = each.key
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  statistic           = each.value.statistic
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.alarm_actions
}
