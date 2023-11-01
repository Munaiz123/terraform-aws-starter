resource "aws_lambda_function" "main_lambda" {
  function_name = "main-lambda"

  s3_bucket = aws_s3_bucket.main_lambda_bucket.id
  s3_key    = aws_s3_object.main.key

  runtime = "nodejs18.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.main_lambda_archive.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "main_log_group" {
  name = "/aws/lambda/${aws_lambda_function.main_lambda.function_name}"

  retention_in_days = 14
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
