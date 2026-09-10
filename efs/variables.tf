variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "encrypted" {
  type    = bool
  default = true
}

variable "create_access_point" {
  type    = bool
  default = true
}
