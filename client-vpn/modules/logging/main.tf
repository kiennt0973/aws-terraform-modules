resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/clientvpn/${var.name}"
  retention_in_days = 30
  tags              = merge(var.tags, { Name = "${var.name}-logs" })
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "connection-log"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}