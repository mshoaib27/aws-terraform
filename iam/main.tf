######################### IAM Role for EC2 SSM Manager Access #########################

# IAM Role for EC2 instances to use SSM Manager
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "tt-uat-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "tt-uat-ec2-ssm-role"
    }
  )
}

# Attach SSM Managed Policy for Session Manager
resource "aws_iam_role_policy_attachment" "ssm_session_manager" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach SSM Managed Policy for Patch Manager
resource "aws_iam_role_policy_attachment" "ssm_patch_manager" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

# IAM Instance Profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "tt-uat-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# CloudWatch Logs Policy for SSM Session Manager logging
resource "aws_iam_role_policy" "ssm_cloudwatch_logs" {
  name   = "tt-uat-ssm-cloudwatch-logs-policy"
  role   = aws_iam_role.ec2_ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# S3 Policy for SSM documents and Session Manager logs
resource "aws_iam_role_policy" "ssm_s3_policy" {
  name   = "tt-uat-ssm-s3-policy"
  role   = aws_iam_role.ec2_ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::aws-ssm-${var.region}/*",
          "arn:aws:s3:::aws-windows-downloads-${var.region}/*"
        ]
      }
    ]
  })
}
