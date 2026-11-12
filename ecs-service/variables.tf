variable "tags" {
  description = "Additional tags applied to taggable resources."
  type        = map(string)
  default     = {}
}

variable "cluster_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_definitions" {
  description = "Rendered ECS container definitions JSON supplied by the caller."
  type        = string
}

variable "efs_volume" {
  description = "Optional EFS access-point volume. Container mountPoints must reference its name."
  type = object({
    name            = string
    file_system_id  = string
    access_point_id = string
  })
  default = null
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type    = string
  default = null
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "assign_public_ip" {
  type    = bool
  default = false
}
