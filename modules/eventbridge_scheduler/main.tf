resource "aws_cloudwatch_event_rule" "weekly_scan"{
  name = "aws_cost_janitor-weekly_trigger-${var.environment}"
  description = "Triggers the lambda fucntion every friday"
  schedule_expression = "cron(0 12 ? * FRI *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.weekly_scan.name
  target_id = "CostJanitorLambda"
  arn = var.lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id = "AllowExecuationFromEventBridge"
  action = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.weekly_scan.arn
}



  
