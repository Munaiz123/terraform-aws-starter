resource "aws_api_gateway_rest_api" "main_lambda_api" {
  name        = "main_lambda_api"
  description = "API for triggering main_lambda"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.main_lambda_api.id
  resource_id   = aws_api_gateway_rest_api.main_lambda_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main_lambda_api.id
  resource_id             = aws_api_gateway_rest_api.main_lambda_api.root_resource_id
  http_method             = aws_api_gateway_method.root_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "dev_deployment" {
  depends_on = [aws_api_gateway_integration.main_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.main_lambda_api.id
  stage_name  = "dev"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_api_gateway_rest_api.main_lambda_api.execution_arn}/*/*"
}
