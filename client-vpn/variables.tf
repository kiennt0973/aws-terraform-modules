variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "client_cidr_block" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets to associate the Client VPN network with (private subnets recommended)"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "server_certificate_arn" {
  description = "ACM certificate ARN for the VPN server (mutual TLS)"
  type        = string
}

variable "client_root_certificate_chain_arn" {
  description = "ACM certificate ARN for client certificate authentication (root CA)"
  type        = string
}

variable "authorized_target_cidrs" {
  description = "CIDR ranges clients are authorized to access (e.g. the VPC CIDR)"
  type        = list(string)
}

variable "split_tunnel" {
  type    = bool
  default = true
}
