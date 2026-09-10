variable "role_name" {
  type = string
}

variable "assume_role_policy_json" {
  type = string
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

# Map of policy name => policy JSON document for inline policies
variable "inline_policies" {
  type    = map(string)
  default = {}
}

variable "path" {
  type    = string
  default = "/"
}
