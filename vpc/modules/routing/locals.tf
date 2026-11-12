locals {
  nat_subnet_ids = var.single_nat_gateway ? {
    (var.primary_az) = var.public_subnet_ids[var.primary_az]
  } : var.public_subnet_ids

  additional_route_table_ids = merge(
    { public = aws_route_table.public.id },
    { for availability_zone, route_table in aws_route_table.private : "private:${availability_zone}" => route_table.id }
  )

  additional_routes = flatten([
    for route in var.additional_routes : [
      for route_table_key, route_table_id in local.additional_route_table_ids : {
        key                        = "${route.name}-${route_table_key}"
        route_table_id             = route_table_id
        destination_cidr_block     = route.destination_cidr_block
        vpc_peering_connection_id  = route.vpc_peering_connection_id
        transit_gateway_id         = route.transit_gateway_id
      }
      if (route.route_table == "public" && route_table_key == "public") ||
      (route.route_table == "private" && startswith(route_table_key, "private:") && (
        route.availability_zone == null || route.availability_zone == trimprefix(route_table_key, "private:")
      ))
    ]
  ])
}
