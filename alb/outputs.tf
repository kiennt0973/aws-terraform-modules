output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "listener_arn" {
  description = "Application listener: HTTPS when configured, otherwise HTTP."
  value       = var.certificate_arn == null ? aws_lb_listener.http.arn : aws_lb_listener.https[0].arn
}
