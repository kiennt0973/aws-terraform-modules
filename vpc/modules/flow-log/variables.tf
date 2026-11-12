variable "create" {
  description = "Whether to create the VPC flow log and related resources."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name used for flow log resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach the flow log to."
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 90
}

variable "traffic_type" {
  description = "Traffic type to capture: ACCEPT, REJECT, or ALL."
  type        = string
  default     = "ALL"
}

variable "log_destination_type" {
  description = "Flow log destination type: cloud-watch-logs or s3."
  type        = string
  default     = "cloud-watch-logs"
}

variable "log_destination" {
  description = "Existing destination ARN for non-CloudWatch flow logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}