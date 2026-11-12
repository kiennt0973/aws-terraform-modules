variable "name" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,30}[A-Za-z0-9]$|^[A-Za-z0-9]$", var.name))
    error_message = "Target group name must be 1-32 alphanumeric or hyphen characters and cannot start or end with a hyphen."
  }
}

variable "vpc_id" {
  type = string
}

variable "port" {
  type = number
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type    = map(string)
  default = {}
}
