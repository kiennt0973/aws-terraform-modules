output "log_group_name" {
  value = aws_cloudwatch_log_group.vpn.name
}

output "log_stream_name" {
  value = aws_cloudwatch_log_stream.vpn.name
}