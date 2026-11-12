variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "user_pool_name" {
  type = string
}

variable "domain_prefix" {
  description = "Optional unique Cognito hosted-login domain prefix for OAuth authorization-code flows."
  type        = string
  default     = null
}

variable "app_client_name" {
  type    = string
  default = "web-client"
}

variable "generate_secret" {
  type    = bool
  default = false
}

variable "callback_urls" {
  type    = list(string)
  default = ["https://localhost/callback"]
}

variable "create_identity_pool" {
  type    = bool
  default = false
}
