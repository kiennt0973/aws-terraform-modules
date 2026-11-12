mock_provider "aws" {}

variables {
  cluster_id            = "arn:aws:ecs:us-east-1:123456789012:cluster/validation"
  service_name          = "validation-service"
  subnet_ids            = ["subnet-00000000000000001"]
  security_group_ids    = ["sg-00000000000000002"]
  execution_role_arn    = "arn:aws:iam::123456789012:role/execution"
  task_role_arn         = "arn:aws:iam::123456789012:role/task"
  container_definitions = "[{\"name\":\"validation-service\",\"image\":\"nginx:latest\",\"essential\":true}]"
}

run "without_efs" {
  command = plan

  assert {
    condition     = length(aws_ecs_task_definition.this.volume) == 0
    error_message = "Omitting efs_volume must preserve task definitions without EFS."
  }
}

run "common_efs" {
  command = plan

  variables {
    efs_volume = {
      name            = "common-efs"
      file_system_id  = "fs-00000000000000001"
      access_point_id = "fsap-00000000000000001"
    }
    container_definitions = jsonencode([{
      name      = "validation-service"
      image     = "nginx:latest"
      essential = true
      mountPoints = [{
        sourceVolume  = "common-efs"
        containerPath = "/data"
        readOnly      = false
      }]
    }])
  }

  assert {
    condition = (
      length(aws_ecs_task_definition.this.volume) == 1 &&
      one(aws_ecs_task_definition.this.volume).name == "common-efs" &&
      one(one(aws_ecs_task_definition.this.volume).efs_volume_configuration).file_system_id == var.efs_volume.file_system_id &&
      one(one(aws_ecs_task_definition.this.volume).efs_volume_configuration).root_directory == "/" &&
      one(one(aws_ecs_task_definition.this.volume).efs_volume_configuration).transit_encryption == "ENABLED" &&
      one(one(one(aws_ecs_task_definition.this.volume).efs_volume_configuration).authorization_config).access_point_id == var.efs_volume.access_point_id &&
      one(one(one(aws_ecs_task_definition.this.volume).efs_volume_configuration).authorization_config).iam == "ENABLED"
    )
    error_message = "The EFS task volume must use the common access point with root /, TLS, and IAM authorization."
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].mountPoints == [{
      sourceVolume  = "common-efs"
      containerPath = "/data"
      readOnly      = false
    }]
    error_message = "The common volume must be mounted read/write at /data."
  }
}
