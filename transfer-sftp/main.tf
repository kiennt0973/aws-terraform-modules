data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "transfer" {
  name               = "${var.name}-transfer-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "transfer_s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [var.s3_bucket_arn]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
    ]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "transfer_s3" {
  name   = "${var.name}-s3-access"
  role   = aws_iam_role.transfer.id
  policy = data.aws_iam_policy_document.transfer_s3.json
}

resource "aws_transfer_server" "this" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols               = ["SFTP"]
  endpoint_type           = var.endpoint_type

  dynamic "endpoint_details" {
    for_each = var.endpoint_type == "VPC" ? [1] : []
    content {
      vpc_id             = var.vpc_id
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = { Name = var.name }
}

resource "aws_transfer_user" "demo" {
  server_id = aws_transfer_server.this.id
  user_name = "demo"
  role      = aws_iam_role.transfer.arn

  home_directory = "/${var.s3_bucket_name}/demo"
}
