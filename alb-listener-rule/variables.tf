variable "listener_arn" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "priority" {
  description = "Listener rule priority. Null lets the AWS provider assign the next available priority after the current highest rule."
  type        = number
  default     = null
  validation {
    condition     = var.priority == null ? true : (var.priority >= 1 && var.priority <= 50000 && floor(var.priority) == var.priority)
    error_message = "Listener rule priority must be an integer between 1 and 50000."
  }
}

variable "path_patterns" {
  type = list(string)
  validation {
    condition     = length(var.path_patterns) >= 1 && length(var.path_patterns) <= 3
    error_message = "Supply one to three listener path patterns."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
