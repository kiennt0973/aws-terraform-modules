resource "aws_vpc" "this" {
  for_each = toset([var.vpc_name])

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.vpc_name })
}

resource "aws_internet_gateway" "this" {
  for_each = toset([var.vpc_name])

  vpc_id = aws_vpc.this[each.key].id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

module "subnets" {
  source   = "./modules/subnets"
  for_each = toset([var.vpc_name])

  name            = var.vpc_name
  vpc_id          = aws_vpc.this[each.key].id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  tags            = var.tags
}

module "routing" {
  source   = "./modules/routing"
  for_each = toset([var.vpc_name])

  name                = var.vpc_name
  vpc_id              = aws_vpc.this[each.key].id
  internet_gateway_id = aws_internet_gateway.this[each.key].id
  public_subnet_ids   = module.subnets[each.key].public_subnet_ids
  private_subnet_ids  = module.subnets[each.key].private_subnet_ids
  single_nat_gateway  = var.single_nat_gateway
  primary_az          = var.azs[0]
  additional_routes   = var.routing_routes
  tags                = var.tags
}

#module "flow_log" {
#  source   = "./modules/flow-log"
#  for_each = toset([var.vpc_name])
#
#  create                = var.create_flow_log
#  name                  = var.vpc_name
#  vpc_id                = aws_vpc.this[each.key].id
#  retention_in_days     = var.flow_log_retention_in_days
#  traffic_type          = var.flow_log_traffic_type
#  log_destination_type  = var.flow_log_destination_type
#  log_destination       = var.flow_log_destination
#  tags                  = var.tags
#}

module "nacl" {
  source   = "./modules/nacl"
  for_each = toset([var.vpc_name])

  name         = var.vpc_name
  vpc_id       = aws_vpc.this[each.key].id
  network_acls = {
    for acl_name, acl in var.network_acls : acl_name => {
      subnet_ids = toset(concat(
        contains(acl.subnet_groups, "public") ?
        values(module.subnets[each.key].public_subnet_ids) : [],
        contains(acl.subnet_groups, "private") ?
        values(module.subnets[each.key].private_subnet_ids) : []
      ))
      rules      = acl.rules
    }
  }
  tags         = var.tags
}
