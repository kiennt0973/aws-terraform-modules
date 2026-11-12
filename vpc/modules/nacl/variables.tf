variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "network_acls" {
  description = "Named network ACLs, each with subnet IDs and ingress/egress rules."
  type = map(object({
    subnet_ids = set(string)
    rules = list(object({
      rule_number = number
      egress      = bool
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = optional(number)
      to_port     = optional(number)
    }))
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
