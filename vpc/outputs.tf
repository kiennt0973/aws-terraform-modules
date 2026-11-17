output "vpc_id" {
  value = one([for vpc in aws_vpc.this : vpc.id])
}

output "vpc_cidr" {
  value = one([for vpc in aws_vpc.this : vpc.cidr_block])
}

output "public_subnet_ids" {
  value = [for az in var.azs : module.subnets[var.vpc_name].public_subnet_ids[az]]
}

output "private_subnet_ids" {
  value = [for az in var.azs : module.subnets[var.vpc_name].private_subnet_ids[az]]
}

output "default_security_group_id" {
  value = one([for vpc in aws_vpc.this : vpc.default_security_group_id])
}

output "public_route_table_ids" {
  value = one([for routing in module.routing : routing.public_route_table_id])
}

output "private_route_table_ids" {
  value = one([for routing in module.routing : routing.private_route_table_ids])
}

#output "flow_log_id" {
#  value = one([for flow_log in module.flow_log : flow_log.id])
#}

#output "flow_log_arn" {
#  value = one([for flow_log in module.flow_log : flow_log.arn])
#}

output "public_network_acl_id" {
  value = module.nacl.network_acl_id
}

output "private_network_acl_id" {
  value = module.nacl.network_acl_id
}

output "network_acl_ids" {
  description = "The VPC's shared network ACL ID keyed by its shared name."
  value       = { shared = module.nacl.network_acl_id }
}
