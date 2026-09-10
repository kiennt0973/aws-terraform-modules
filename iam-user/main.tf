resource "aws_iam_user" "this" {
  name = var.user_name
  path = var.path
}

resource "aws_iam_access_key" "this" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "managed" {
  for_each  = toset(var.managed_policy_arns)
  user      = aws_iam_user.this.name
  policy_arn = each.value
}

resource "aws_iam_user_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  user     = aws_iam_user.this.name
  policy   = each.value
}

resource "aws_iam_user_group_membership" "this" {
  count  = length(var.group_names) > 0 ? 1 : 0
  user   = aws_iam_user.this.name
  groups = var.group_names
}
