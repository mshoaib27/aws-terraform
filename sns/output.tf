output "sns_topic_arns" {
  description = "SNS topic ARNs for alarms"
  value = {
    for email, topic in aws_sns_topic.alarm_topics :
    email => topic.arn
  }
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.alarm_generator.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.alarm_generator.function_name
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name for Lambda scheduling"
  value       = aws_cloudwatch_event_rule.alarm_generator_schedule.name
}
