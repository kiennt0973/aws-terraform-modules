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
}

variable "security_group_ids" {
  type = list(string)
}

variable "internal" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  description = "ACM cert ARN for HTTPS listener. Leave null for HTTP only."
  type        = string
  default     = null
}
