resource "aws_api_gateway_rest_api" "main_lambda_api" {
  name        = "main_lambda_api"
  description = "API for triggering main_lambda"
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.main_lambda_api.root_resource_id
  path_part   = "trigger"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_lambda_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_lambda_api.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method

  type      = "AWS_PROXY"
  uri       = aws_lambda_function.main_lambda.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [aws_api_gateway_integration.main_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.main_lambda_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_api_gateway_rest_api.main_lambda_api.execution_arn}/*/*"
}
