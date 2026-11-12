resource "aws_network_acl" "this" {
  for_each = var.network_acls

  vpc_id     = var.vpc_id
  subnet_ids = each.value.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-${each.key}-nacl" })
}

resource "aws_network_acl_rule" "this" {
  for_each = {
    for rule in flatten([
      for acl_name, acl in var.network_acls : [
        for rule in acl.rules : {
          key      = "${acl_name}-${rule.egress}-${rule.rule_number}"
          acl_name = acl_name
          rule     = rule
        }
      ]
    ]) : rule.key => rule
  }

  network_acl_id = aws_network_acl.this[each.value.acl_name].id
  rule_number     = each.value.rule.rule_number
  egress          = each.value.rule.egress
  protocol        = each.value.rule.protocol
  rule_action     = each.value.rule.rule_action
  cidr_block      = each.value.rule.cidr_block
  from_port       = each.value.rule.from_port
  to_port         = each.value.rule.to_port
}
