variables {
  name                 = "validation-apigw"
  lambda_invoke_arn    = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:validation/invocations"
  lambda_function_name = "validation"
}

run "rest_api_lambda_proxy" {
  command = plan

  assert {
    condition = (
      aws_api_gateway_rest_api.this.endpoint_configuration[0].types == toset(["REGIONAL"]) &&
      aws_api_gateway_method.root.http_method == "ANY" &&
      aws_api_gateway_method.proxy.http_method == "ANY" &&
      aws_api_gateway_resource.proxy.path_part == "{proxy+}"
    )
    error_message = "The REST API must expose root and proxy ANY routes on a regional endpoint."
  }

  assert {
    condition = (
      aws_api_gateway_integration.root.type == "AWS_PROXY" &&
      aws_api_gateway_integration.proxy.type == "AWS_PROXY" &&
      aws_api_gateway_integration.root.integration_http_method == "POST" &&
      aws_api_gateway_integration.proxy.integration_http_method == "POST" &&
      aws_api_gateway_integration.root.uri == var.lambda_invoke_arn &&
      aws_api_gateway_integration.proxy.uri == var.lambda_invoke_arn
    )
    error_message = "Both REST API routes must forward requests to the configured Lambda proxy integration."
  }

  assert {
    condition = (
      aws_lambda_permission.apigw.function_name == var.lambda_function_name &&
      aws_lambda_permission.apigw.source_arn == "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*" &&
      aws_api_gateway_stage.this.stage_name == "prod"
    )
    error_message = "API Gateway must be permitted to invoke the Lambda function and deploy to the default stage."
  }
}

run "missing_lambda_rejected" {
  command = plan

  variables {
    lambda_invoke_arn    = null
    lambda_function_name = null
  }

  expect_failures = [aws_api_gateway_rest_api.this]
}

run "incomplete_lambda_rejected" {
  command = plan

  variables {
    lambda_invoke_arn    = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:validation/invocations"
    lambda_function_name = null
  }

  expect_failures = [aws_api_gateway_rest_api.this]
}
