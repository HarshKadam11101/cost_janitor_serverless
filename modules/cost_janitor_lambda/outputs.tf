output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "The ARN of the Cost Janitor Lambda function"
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
  description = "Name of the Fucntion"
}