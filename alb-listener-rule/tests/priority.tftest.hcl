mock_provider "aws" {}

variables {
  listener_arn     = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/mock/0000000000000000/0000000000000000"
  target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock/0000000000000000"
  path_patterns    = ["/*"]
}

run "automatic_priority" {
  command = plan
}

run "explicit_null_priority" {
  command = plan
  variables {
    priority = null
  }
}

run "explicit_priority" {
  command = plan
  variables {
    priority = 200
  }
  assert {
    condition     = aws_lb_listener_rule.this.priority == 200
    error_message = "An explicit priority must be passed unchanged to the listener rule."
  }
}

run "minimum_priority" {
  command = plan
  variables {
    priority = 1
  }
  assert {
    condition     = aws_lb_listener_rule.this.priority == 1
    error_message = "Priority 1 must be accepted."
  }
}

run "maximum_priority" {
  command = plan
  variables {
    priority = 50000
  }
  assert {
    condition     = aws_lb_listener_rule.this.priority == 50000
    error_message = "Priority 50000 must be accepted."
  }
}

run "zero_priority_rejected" {
  command = plan
  variables {
    priority = 0
  }
  expect_failures = [var.priority]
}

run "negative_priority_rejected" {
  command = plan
  variables {
    priority = -1
  }
  expect_failures = [var.priority]
}

run "out_of_range_priority_rejected" {
  command = plan
  variables {
    priority = 50001
  }
  expect_failures = [var.priority]
}

run "fractional_priority_rejected" {
  command = plan
  variables {
    priority = 1.5
  }
  expect_failures = [var.priority]
}
