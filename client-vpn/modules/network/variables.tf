variable "client_vpn_endpoint_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "authorized_target_cidrs" {
  type = list(string)
}