module "sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  name  = "test"
  create = true
  create_subscription = true
  create_topic_policy = true
  display_name = "test-sns"


  topic_policy_statements = {
    pub = {
      actions = ["sns:Publish"]
      principals = [{
        type        = "AWS"
        identifiers = [data.aws_caller_identity.current.arn]
      }]
    },

    sub = {
      actions = [
        "sns:Subscribe",
        "sns:Receive",
      ]

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      conditions = [{
        test     = "StringLike"
        variable = "sns:Endpoint"
        values   = [module.sqs.queue_arn]
      }]
    }
  }

  subscriptions = {
    sqs = {
      protocol = "sqs"
      endpoint = module.sqs.queue_arn
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.0"

  name       = "test"
  fifo_queue = true

  create_queue_policy = true
  queue_policy_statements = {
    sns = {
      sid     = "SNS"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = [module.complete_sns.topic_arn]
        }
      ]
    }
  }
}