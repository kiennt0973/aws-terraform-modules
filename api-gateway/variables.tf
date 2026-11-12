variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  type = string
}

variable "lambda_invoke_arn" {
  type    = string
  default = null
}

variable "lambda_function_name" {
  type    = string
  default = null
}

variable "stage_name" {
  type    = string
  default = "prod"
}
