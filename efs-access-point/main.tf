resource "aws_efs_access_point" "this" {
  file_system_id = var.file_system_id

  posix_user {
    uid = var.uid
    gid = var.gid
  }

  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_uid   = var.uid
      owner_gid   = var.gid
      permissions = var.permissions
    }
  }

  tags = merge(var.tags, { Name = var.name })
}
