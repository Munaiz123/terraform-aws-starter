output "function_name" {
  description = "App's backend lambda"
  value = aws_lambda_function.main_lambda.function_name
}
