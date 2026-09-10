variable "vpc_id" {
  type = string
}

# Map of security group definitions.
# key = logical name, value = { description, ingress = [ {description, from_port, to_port, protocol, cidr_blocks, self, source_sg_key} ], egress = [ ... ] }
variable "security_groups" {
  type = map(object({
    description = string
    ingress = list(object({
      description    = optional(string, "")
      from_port      = number
      to_port        = number
      protocol       = string
      cidr_blocks    = optional(list(string), [])
      source_sg_key  = optional(string, null)
      self           = optional(bool, false)
    }))
    egress = optional(list(object({
      description = optional(string, "")
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
    })), [{
      description = "all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }])
  }))
}
