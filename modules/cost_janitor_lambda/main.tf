data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.root}/src/app.py"
  output_path = "${path.root}/lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.lambda_code.output_path
  function_name    = "cost_janoitor_function"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  handler = "app.lambda_handler"
  runtime = "python3.10"
  timeout = 30

  role = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      "SNS_TOPIC_ARN" = var.sns_arn
    }
  }
}