variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "endpoint_type" {
  type    = string
  default = "VPC"
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}
