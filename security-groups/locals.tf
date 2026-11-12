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
        source_sg_id  = rule.source_sg_id
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
