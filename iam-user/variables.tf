variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "user_name" {
  type = string
}

variable "path" {
  type    = string
  default = "/"
}

variable "create_access_key" {
  type    = bool
  default = false
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type    = map(string)
  default = {}
}

variable "group_names" {
  type    = list(string)
  default = []
}
