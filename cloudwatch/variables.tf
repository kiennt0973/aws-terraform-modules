variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "log_group_names" {
  type = list(string)
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    metric_name         = string
    namespace           = string
    statistic           = string
    period              = number
    evaluation_periods  = number
    threshold           = number
    comparison_operator = string
    dimensions          = map(string)
    alarm_actions       = optional(list(string), [])
  }))
  default = {}
}
