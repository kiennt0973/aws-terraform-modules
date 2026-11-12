module "logging" {
  source = "./modules/logging"

  name = var.name
  tags = var.tags
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.name
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  vpc_id                 = var.vpc_id
  security_group_ids     = var.security_group_ids
  split_tunnel           = var.split_tunnel
  transport_protocol     = "udp"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_root_certificate_chain_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group   = module.logging.log_group_name
    cloudwatch_log_stream  = module.logging.log_stream_name
  }

  tags = merge(var.tags, { Name = var.name })
}

module "network" {
  source = "./modules/network"

  client_vpn_endpoint_id   = aws_ec2_client_vpn_endpoint.this.id
  subnet_ids               = var.subnet_ids
  authorized_target_cidrs  = var.authorized_target_cidrs
}
