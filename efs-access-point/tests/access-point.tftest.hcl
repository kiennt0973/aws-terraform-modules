mock_provider "aws" {}

variables {
  name                = "service-a-ap"
  file_system_id      = "fs-00000000000000001"
  root_directory_path = "/service-a"
  uid                 = 1000
  gid                 = 1000
}

run "service_a" {
  command = plan

  assert {
    condition = (
      aws_efs_access_point.this.file_system_id == var.file_system_id &&
      aws_efs_access_point.this.root_directory[0].path == "/service-a" &&
      aws_efs_access_point.this.posix_user[0].uid == 1000 &&
      aws_efs_access_point.this.root_directory[0].creation_info[0].owner_uid == 1000 &&
      aws_efs_access_point.this.root_directory[0].creation_info[0].permissions == "0755"
    )
    error_message = "Service A must use its own directory and configured POSIX identity."
  }
}

run "service_b" {
  command = plan

  variables {
    name                = "service-b-ap"
    root_directory_path = "/service-b"
    uid                 = 1001
    gid                 = 1001
  }

  assert {
    condition = (
      aws_efs_access_point.this.file_system_id == var.file_system_id &&
      aws_efs_access_point.this.root_directory[0].path == "/service-b" &&
      aws_efs_access_point.this.posix_user[0].uid == 1001 &&
      aws_efs_access_point.this.posix_user[0].gid == 1001 &&
      aws_efs_access_point.this.root_directory[0].creation_info[0].owner_gid == 1001
    )
    error_message = "Service B must use the same EFS with its own directory and POSIX identity."
  }
}
