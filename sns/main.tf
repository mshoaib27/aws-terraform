data "aws_caller_identity" "current" {}

locals {
  lambda_name = "cw-alarm-generator"
  role_name   = "cw-alarm-generator-role"
}

resource "aws_iam_role" "lambda_role" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "cw-alarm-generator-policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "rds:Describe*",
          "elasticfilesystem:Describe*",
          "elasticloadbalancing:Describe*",
          "cloudwatch:PutMetricAlarm",
          "sns:Publish",
          "acm:ListCertificates"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sns_topic" "alarm_topics" {
  for_each = toset(var.emails)

  name = "nexsysone-${replace(replace(split("@", each.value)[0], ".", "-"), "_", "-")}-sns-topic"

  tags = merge(
    var.tags,
    {
      Name = "nexsysone-${replace(replace(split("@", each.value)[0], ".", "-"), "_", "-")}-sns-topic"
    }
  )
}

resource "aws_sns_topic_subscription" "alarm_emails" {
  for_each = toset(var.emails)

  topic_arn = aws_sns_topic.alarm_topics[each.value].arn
  protocol  = "email"
  endpoint  = each.value
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "alarm_generator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  publish          = true

  environment {
    variables = {
      CUSTOMER                    = var.customer_name
      ENV                         = var.environment
      AWS_REGION                  = var.region
      SNS_TOPIC_ARN_INFRA         = aws_sns_topic.alarm_topics["infra@nexsysone.com"].arn
      SNS_TOPIC_ARN_PERFORMANCE   = aws_sns_topic.alarm_topics["performance@nxsysone.com"].arn
      SNS_TOPIC_ARN_SUPPORT       = aws_sns_topic.alarm_topics["support.automation@nexsysone.com"].arn
      SNS_TOPIC_ARN_TIER1         = aws_sns_topic.alarm_topics["nxosupport.tier1@nexsysone.com"].arn
      SNS_TOPIC_ARN_LEADS         = aws_sns_topic.alarm_topics["Leads@nexsysone.com"].arn
      SNS_TOPIC_ARN_PRODUCT_DEV   = aws_sns_topic.alarm_topics["Product.dev@nexsysone.com"].arn
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = merge(
    var.tags,
    {
      Name = local.lambda_name
    }
  )
}

resource "aws_lambda_invocation" "alarm_generator_trigger" {
  function_name = aws_lambda_function.alarm_generator.function_name
  input         = jsonencode({})

  triggers = {
    redeployment = aws_lambda_function.alarm_generator.source_code_hash
  }
}

resource "aws_cloudwatch_event_rule" "alarm_generator_schedule" {
  name                = "cw-alarm-generator-schedule"
  description         = "Trigger CloudWatch alarm generator Lambda daily"
  schedule_expression = "cron(0 2 * * ? *)"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "alarm_generator_target" {
  rule      = aws_cloudwatch_event_rule.alarm_generator_schedule.name
  target_id = "CWAlarmGeneratorLambda"
  arn       = aws_lambda_function.alarm_generator.arn

  depends_on = [aws_lambda_permission.allow_eventbridge]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alarm_generator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_generator_schedule.arn
}
