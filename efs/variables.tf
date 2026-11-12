variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.subnet_ids) == length(distinct(var.subnet_ids))
    error_message = "subnet_ids must not contain duplicates."
  }
}

variable "security_group_ids" {
  type = list(string)
}

variable "encrypted" {
  type    = bool
  default = true
}
