output "id" {
  description = "The ID of the VPC flow log."
  value       = try(aws_flow_log.this[0].id, null)
}

output "arn" {
  description = "The ARN of the VPC flow log."
  value       = try(aws_flow_log.this[0].arn, null)
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group."
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "iam_role_arn" {
  description = "The ARN of the flow log IAM role."
  value       = try(aws_iam_role.this[0].arn, null)
}