variable "tags" {
  description = "Additional tags applied to the VPC and its resources."
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name prefix for the VPC and its resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "azs" {
  description = "Availability zones in which to create subnets."
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0 && length(var.azs) == length(distinct(var.azs))
    error_message = "azs must contain at least one unique availability zone."
  }
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR for each availability zone."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs must have one CIDR for each availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR for each availability zone."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs must have one CIDR for each availability zone."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway shared by private subnets instead of one per availability zone."
  type        = bool
  default     = true
}

variable "routing_routes" {
  description = "Additional routes to add to the VPC route tables."
  type = list(object({
    name                      = string
    route_table               = string
    destination_cidr_block    = string
    availability_zone         = optional(string)
    vpc_peering_connection_id = optional(string)
    transit_gateway_id        = optional(string)
  }))
  default = []
}

variable "create_flow_log" {
  description = "Whether to create a VPC flow log."
  type        = bool
  default     = false
}

variable "flow_log_retention_in_days" {
  description = "CloudWatch log retention in days when the module creates the flow log group."
  type        = number
  default     = 90
}

variable "flow_log_traffic_type" {
  description = "Traffic type captured by the VPC flow log."
  type        = string
  default     = "ALL"
}

variable "flow_log_destination_type" {
  description = "Destination type for the VPC flow log."
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_log_destination" {
  description = "Optional destination ARN for the VPC flow log."
  type        = string
  default     = null
}

variable "network_acl_rules" {
  description = "CIDR-matched ingress and egress rules for the VPC's single shared network ACL."
  type = list(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
  default = [
    { rule_number = 100, egress = false, protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" },
    { rule_number = 100, egress = true, protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" },
  ]

  validation {
    condition = length(var.network_acl_rules) == length(distinct([
      for rule in var.network_acl_rules : "${rule.egress}-${rule.rule_number}"
    ]))
    error_message = "NACL rule numbers must be unique for ingress and egress within the shared ACL."
  }
}
