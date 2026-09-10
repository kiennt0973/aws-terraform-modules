variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "route_table_ids" {
  description = "Route table IDs for the S3 gateway endpoint"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "interface_services" {
  description = "AWS service names (short form) to create interface endpoints for"
  type        = list(string)
  default = [
    "ecr.api",
    "ecr.dkr",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "logs",
    "secretsmanager",
    "ssm",
    "ssmmessages",
    "ec2messages",
  ]
}
