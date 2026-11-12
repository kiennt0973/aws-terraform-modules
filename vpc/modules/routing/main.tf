resource "aws_eip" "nat" {
  for_each = local.nat_subnet_ids
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.name}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each      = local.nat_subnet_ids
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value
  tags          = merge(var.tags, { Name = "${var.name}-nat-${each.key}" })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id              = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.nat_subnet_ids
  vpc_id   = var.vpc_id
  tags     = merge(var.tags, { Name = "${var.name}-private-rt-${each.key}" })
}

resource "aws_route" "private_nat" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each  = var.private_subnet_ids
  subnet_id = each.value
  route_table_id = var.single_nat_gateway ? aws_route_table.private[var.primary_az].id : aws_route_table.private[each.key].id
}

resource "aws_route" "additional" {
  for_each = { for route in local.additional_routes : route.key => route }

  route_table_id              = each.value.route_table_id
  destination_cidr_block      = each.value.destination_cidr_block
  vpc_peering_connection_id   = each.value.vpc_peering_connection_id
  transit_gateway_id          = each.value.transit_gateway_id
}