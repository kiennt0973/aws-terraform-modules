output "public_subnet_ids" {
  value = { for availability_zone, subnet in aws_subnet.public : availability_zone => subnet.id }
}

output "private_subnet_ids" {
  value = { for availability_zone, subnet in aws_subnet.private : availability_zone => subnet.id }
}