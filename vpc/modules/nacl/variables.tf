variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "rules" {
  type = list(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
