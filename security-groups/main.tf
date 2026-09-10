resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = { Name = each.key }
}

locals {
  ingress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in sg.ingress : {
        sg_key        = sg_key
        idx           = idx
        description   = rule.description
        from_port     = rule.from_port
        to_port       = rule.to_port
        protocol      = rule.protocol
        cidr_blocks   = rule.cidr_blocks
        self          = rule.self
        source_sg_key = rule.source_sg_key
      }
    ]
  ])

  egress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in sg.egress : {
        sg_key      = sg_key
        idx         = idx
        description = rule.description
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr_blocks = rule.cidr_blocks
      }
    ]
  ])
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for r in local.ingress_rules : "${r.sg_key}-in-${r.idx}" => r }

  type                     = "ingress"
  security_group_id        = aws_security_group.this[each.value.sg_key].id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  self                     = each.value.self ? true : null
  source_security_group_id = each.value.source_sg_key != null ? aws_security_group.this[each.value.source_sg_key].id : null
}

resource "aws_security_group_rule" "egress" {
  for_each = { for r in local.egress_rules : "${r.sg_key}-out-${r.idx}" => r }

  type              = "egress"
  security_group_id = aws_security_group.this[each.value.sg_key].id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}
