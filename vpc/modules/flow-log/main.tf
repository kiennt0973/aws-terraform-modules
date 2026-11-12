resource "aws_cloudwatch_log_group" "this" {
  count = local.create_cloudwatch_resources ? 1 : 0

  name              = "/aws/vpc/${var.name}/flow-log"
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_cloudwatch_resources ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  count = local.create_cloudwatch_resources ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.this[0].arn}:*"]
  }
}

resource "aws_iam_role" "this" {
  count = local.create_cloudwatch_resources ? 1 : 0

  name               = "${var.name}-vpc-flow-log"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  count = local.create_cloudwatch_resources ? 1 : 0

  name   = "${var.name}-vpc-flow-log"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_flow_log" "this" {
  count = var.create ? 1 : 0

  iam_role_arn         = local.create_cloudwatch_resources ? aws_iam_role.this[0].arn : null
  log_destination      = local.create_cloudwatch_resources ? aws_cloudwatch_log_group.this[0].arn : var.log_destination
  log_destination_type = var.log_destination_type
  traffic_type         = var.traffic_type
  vpc_id               = var.vpc_id
  tags                 = var.tags
}