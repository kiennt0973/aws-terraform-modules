resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/clientvpn/${var.name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "connection-log"
  log_group_name = aws_cloudwatch_log_group.vpn.name
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
    cloudwatch_log_group   = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream  = aws_cloudwatch_log_stream.vpn.name
  }

  tags = { Name = var.name }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  count                  = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.subnet_ids[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  count                  = length(var.authorized_target_cidrs)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.authorized_target_cidrs[count.index]
  authorize_all_groups   = true

  depends_on = [aws_ec2_client_vpn_network_association.this]
}

resource "aws_ec2_client_vpn_route" "this" {
  count                  = length(var.authorized_target_cidrs)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = var.authorized_target_cidrs[count.index]
  target_vpc_subnet_id   = var.subnet_ids[0]

  depends_on = [aws_ec2_client_vpn_network_association.this]
}
