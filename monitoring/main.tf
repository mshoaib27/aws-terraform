data "aws_caller_identity" "current" {}

locals {
  email_prefix_map = {
    for email in var.notification_emails :
    email => replace(replace(lower(split("@", email)[0]), ".", "-"), "_", "-")
  }
}

resource "aws_sns_topic" "notification" {
  for_each = toset(var.notification_emails)

  name = "nexsysone-${local.email_prefix_map[each.value]}-sns-topic"

  tags = merge(
    var.tags,
    {
      Name = "nexsysone-${local.email_prefix_map[each.value]}-sns-topic"
    }
  )
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.notification[each.value].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.customer_name}-${var.environment}-cw-alarm-lambda-role"

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

  tags = merge(
    var.tags,
    {
      Name = "${var.customer_name}-${var.environment}-cw-alarm-lambda-role"
    }
  )
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.customer_name}-${var.environment}-cw-alarm-lambda-policy"
  role = aws_iam_role.lambda_role.id

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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "alarm_generator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.customer_name}-cw-alarm-generator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CUSTOMER                    = var.customer_name
      ENV                         = var.environment
      AWS_REGION                  = var.region
      SNS_TOPIC_ARN_INFRA         = aws_sns_topic.notification["infra@nexsysone.com"].arn
      SNS_TOPIC_ARN_PERFORMANCE   = aws_sns_topic.notification["performance@nxsysone.com"].arn
      SNS_TOPIC_ARN_SUPPORT       = aws_sns_topic.notification["support.automation@nexsysone.com"].arn
      SNS_TOPIC_ARN_TIER1         = aws_sns_topic.notification["nxosupport.tier1@nexsysone.com"].arn
      SNS_TOPIC_ARN_LEADS         = aws_sns_topic.notification["Leads@nexsysone.com"].arn
      SNS_TOPIC_ARN_PRODUCT_DEV   = aws_sns_topic.notification["Product.dev@nexsysone.com"].arn
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.customer_name}-cw-alarm-generator"
    }
  )

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_sns_topic.notification
  ]
}

resource "aws_lambda_invocation" "trigger" {
  function_name = aws_lambda_function.alarm_generator.function_name
  input         = jsonencode({})

  triggers = {
    redeployment = base64sha256(jsonencode({
      role_arn = aws_iam_role.lambda_role.arn
      lambda   = aws_lambda_function.alarm_generator.function_name
    }))
  }
}
