variable "cluster_name" {
  description = "Name of the EKS cluster and its managed node group."
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 49
    error_message = "cluster_name must be between 1 and 49 characters so generated IAM role and node group names fit AWS limits."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster. When null, AWS selects the default supported version."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Private subnet IDs for the EKS control plane and managed node group. Provide subnets in at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(distinct(var.subnet_ids)) >= 2
    error_message = "subnet_ids must contain at least two distinct subnet IDs."
  }
}

variable "cluster_log_types" {
  description = "EKS control plane log types to send to CloudWatch Logs."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for log_type in var.cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "cluster_log_types can contain only EKS-supported control plane log types."
  }
}

variable "node_group_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_group_instance_types) > 0
    error_message = "node_group_instance_types must contain at least one instance type."
  }
}

variable "node_group_capacity_type" {
  description = "Capacity type for the managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_group_capacity_type)
    error_message = "node_group_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_group_scaling_config" {
  description = "Desired, minimum, and maximum node counts for the managed node group."
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  validation {
    condition = (
      var.node_group_scaling_config.min_size >= 0 &&
      var.node_group_scaling_config.min_size <= var.node_group_scaling_config.desired_size &&
      var.node_group_scaling_config.desired_size <= var.node_group_scaling_config.max_size
    )
    error_message = "node_group_scaling_config must satisfy min_size <= desired_size <= max_size."
  }
}

variable "irsa_roles" {
  description = "IAM role name => one trusted Kubernetes namespace/service account and its AWS permission policies. Service accounts are managed by the caller."
  type = map(object({
    namespace            = string
    service_account_name = string
    managed_policy_arns  = optional(list(string), [])
    inline_policies      = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, role in var.irsa_roles :
      can(regex("^[A-Za-z0-9_+=,.@-]{1,64}$", name)) &&
      length(role.namespace) <= 63 &&
      can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", role.namespace)) &&
      length(role.service_account_name) <= 253 &&
      alltrue([
        for label in split(".", role.service_account_name) :
        length(label) <= 63 && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", label))
      ])
    ])
    error_message = "IRSA keys must be valid IAM role names (1-64 characters); namespace and service_account_name must be exact Kubernetes names without wildcards."
  }
}

variable "addons" {
  description = "Managed add-on name => optional pinned version and IRSA role name from irsa_roles. Every defined entry is created. Omitted versions use the EKS default compatible version."
  type = map(object({
    addon_version             = optional(string)
    service_account_role_name = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to EKS and IAM resources."
  type        = map(string)
  default     = {}
}
