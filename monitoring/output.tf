output "lambda_function_arn" {
  description = "ARN of the CloudWatch alarm generator Lambda function"
  value       = aws_lambda_function.alarm_generator.arn
}

output "lambda_function_name" {
  description = "Name of the CloudWatch alarm generator Lambda function"
  value       = aws_lambda_function.alarm_generator.function_name
}

output "sns_topic_arns" {
  description = "SNS topic ARNs for notifications"
  value = {
    for email, topic in aws_sns_topic.notification :
    email => topic.arn
  }
}

output "sns_infra_topic_arn" {
  description = "SNS topic ARN for infrastructure notifications"
  value       = aws_sns_topic.notification["infra@nexsysone.com"].arn
}

output "sns_performance_topic_arn" {
  description = "SNS topic ARN for performance notifications"
  value       = aws_sns_topic.notification["performance@nxsysone.com"].arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}
