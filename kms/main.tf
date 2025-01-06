resource "aws_iam_role" "kms_key_admin" {
  name               = "kms-key-administrator"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com" 
        }
      }
    ]
  })

  tags = {
    Name = "KMS Key Administrator Role"
  }
}

resource "aws_iam_policy" "kms_key_admin_policy" {
  name        = "kms-key-administrator-policy"
  description = "Policy to allow administration of KMS keys"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:CreateKey",
          "kms:DescribeKey",
          "kms:EnableKey",
          "kms:DisableKey",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ListAliases",
          "kms:ListKeys",
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

module "kms" {
  source = "terraform-aws-modules/kms/aws"
  aliases = ["test-efs"]

  description = "efs encryption key"
  key_usage = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  multi_region = false
 

  key_administrators = [aws_iam_role.kms_key_admin.arn]
  enable_key_rotation     = false
  is_enabled = true

  tags = {
    Name = "shoaib"
    environment = "dev"
  }
  grants = {
    efs = {
        operations = ["Encrypt","Decrypt","GenerateDataKey"]
        grantee_principal = "efs.amazonaws.com"
        
}
}
}