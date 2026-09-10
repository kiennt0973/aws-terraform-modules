variable "user_pool_name" {
  type = string
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
