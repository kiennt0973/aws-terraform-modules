mock_provider "aws" {}

variables {
  name               = "test-alb"
  subnet_ids         = ["subnet-00000000000000001", "subnet-00000000000000002"]
  security_group_ids = ["sg-00000000000000001"]
}

run "http_default" {
  command = plan

  assert {
    condition     = aws_lb_listener.http.default_action[0].type == "fixed-response" && aws_lb_listener.http.default_action[0].fixed_response[0].status_code == "404"
    error_message = "HTTP must return 404 until an application forwarding rule is added."
  }

  assert {
    condition     = length(aws_lb_listener.https) == 0
    error_message = "HTTP-only deployments must not create an HTTPS listener."
  }
}

run "https_redirect" {
  command = plan

  variables {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = aws_lb_listener.http.default_action[0].type == "redirect" && aws_lb_listener.http.default_action[0].redirect[0].port == "443"
    error_message = "HTTP must redirect to HTTPS when a certificate is supplied."
  }

  assert {
    condition     = aws_lb_listener.https[0].default_action[0].type == "fixed-response" && aws_lb_listener.https[0].default_action[0].fixed_response[0].status_code == "404"
    error_message = "HTTPS must return 404 until an application forwarding rule is added."
  }
}
