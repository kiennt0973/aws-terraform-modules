variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type = string
}

# Map of security group definitions.
# key = logical name; ingress rules can reference an in-module key or an external security group ID.
variable "security_groups" {
  type = map(object({
    description = string
    ingress = list(object({
      description   = optional(string, "")
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string), [])
      source_sg_key = optional(string, null)
      source_sg_id  = optional(string, null)
      self          = optional(bool, false)
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
