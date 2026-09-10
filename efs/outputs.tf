output "file_system_id" {
  value = aws_efs_file_system.this.id
}

output "file_system_arn" {
  value = aws_efs_file_system.this.arn
}

output "access_point_id" {
  value = var.create_access_point ? aws_efs_access_point.this[0].id : null
}
