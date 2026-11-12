output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_ids" {
  value = { for availability_zone, route_table in aws_route_table.private : availability_zone => route_table.id }
}