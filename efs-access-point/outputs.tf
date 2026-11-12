output "access_point_id" {
  value = aws_efs_access_point.this.id
}

output "access_point_arn" {
  value = aws_efs_access_point.this.arn
}

output "file_system_id" {
  value = aws_efs_access_point.this.file_system_id
}
