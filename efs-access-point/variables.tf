variable "name" {
  type = string
}

variable "file_system_id" {
  description = "Existing EFS file system shared by one or more access points."
  type        = string
}

variable "root_directory_path" {
  description = "Service directory exposed as the access point's root."
  type        = string
  validation {
    condition     = startswith(var.root_directory_path, "/") && length(var.root_directory_path) <= 100 && length(compact(split("/", var.root_directory_path))) <= 4
    error_message = "The root directory must be an absolute path of at most 100 characters and four directory levels."
  }
}

variable "uid" {
  type    = number
  default = 1000
  validation {
    condition     = var.uid >= 0 && var.uid <= 4294967295 && floor(var.uid) == var.uid
    error_message = "uid must be an integer between 0 and 4294967295."
  }
}

variable "gid" {
  type    = number
  default = 1000
  validation {
    condition     = var.gid >= 0 && var.gid <= 4294967295 && floor(var.gid) == var.gid
    error_message = "gid must be an integer between 0 and 4294967295."
  }
}

variable "permissions" {
  description = "POSIX permissions used when EFS creates a missing root directory."
  type        = string
  default     = "0755"
  validation {
    condition     = can(regex("^[0-7]{3,4}$", var.permissions))
    error_message = "permissions must contain three or four octal digits."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
