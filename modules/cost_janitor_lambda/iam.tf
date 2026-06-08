resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/aws-cost-janitor-${var.env}"
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "cost-janitor-lambda-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }, ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "cost-janitor-lambda-policy-${var.env}"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["ec2:DescribeVolumes", "ec2:DescribeAddresses"]
      Effect   = "Allow"
      Resource = "*"
      }, {
      Action   = "sns:Publish"
      Effect   = "Allow"
      Resource = var.sns_arn
      }, {
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
    }]
  })
}