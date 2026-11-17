resource "aws_network_acl" "this" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-nacl" })
}

resource "aws_network_acl_rule" "this" {
  for_each = { for rule in var.rules : "${rule.egress}-${rule.rule_number}" => rule }

  network_acl_id = aws_network_acl.this.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}
