# VPC Flow Log submodule

Creates a VPC flow log. CloudWatch destinations create the log group, IAM role,
and inline policy inside this submodule. S3 destinations use the ARN supplied in
`log_destination`.