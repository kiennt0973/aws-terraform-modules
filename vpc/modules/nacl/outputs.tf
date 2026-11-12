output "network_acl_ids" {
  description = "Network ACL IDs keyed by the configured network ACL name."
  value       = { for name, acl in aws_network_acl.this : name => acl.id }
}
