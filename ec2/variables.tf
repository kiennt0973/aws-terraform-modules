variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type    = string
  default = null
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "user_data" {
  type    = string
  default = null
}
