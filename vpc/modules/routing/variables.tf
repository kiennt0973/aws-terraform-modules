variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "public_subnet_ids" {
  type = map(string)
}

variable "private_subnet_ids" {
  type = map(string)
}

variable "single_nat_gateway" {
  type = bool
}

variable "primary_az" {
  type = string
}

variable "additional_routes" {
  description = "Optional routes to a VPC peering connection or Transit Gateway. Private routes apply to every private route table unless availability_zone is set."
  type = list(object({
    name                       = string
    route_table                = string
    destination_cidr_block     = string
    availability_zone          = optional(string)
    vpc_peering_connection_id  = optional(string)
    transit_gateway_id         = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.additional_routes : contains(["public", "private"], route.route_table)
    ])
    error_message = "Each additional route route_table must be either public or private."
  }

  validation {
    condition = alltrue([
      for route in var.additional_routes : (
        (route.vpc_peering_connection_id != null ? 1 : 0) +
        (route.transit_gateway_id != null ? 1 : 0)
      ) == 1
    ])
    error_message = "Each additional route must set exactly one of vpc_peering_connection_id or transit_gateway_id."
  }
}