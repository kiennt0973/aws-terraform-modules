resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = toset(var.subnet_ids)
  client_vpn_endpoint_id = var.client_vpn_endpoint_id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  for_each               = toset(var.authorized_target_cidrs)
  client_vpn_endpoint_id = var.client_vpn_endpoint_id
  target_network_cidr    = each.value
  authorize_all_groups   = true

  depends_on = [aws_ec2_client_vpn_network_association.this]
}

resource "aws_ec2_client_vpn_route" "this" {
  for_each               = toset(var.authorized_target_cidrs)
  client_vpn_endpoint_id = var.client_vpn_endpoint_id
  destination_cidr_block = each.value
  target_vpc_subnet_id   = var.subnet_ids[0]

  depends_on = [aws_ec2_client_vpn_network_association.this]
}