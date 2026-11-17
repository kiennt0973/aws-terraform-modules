output "network_acl_id" {
  description = "The VPC's shared network ACL ID."
  value       = aws_network_acl.this.id
}
