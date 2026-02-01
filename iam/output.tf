output "ec2_ssm_role_arn" {
  description = "ARN of the EC2 SSM role"
  value       = aws_iam_role.ec2_ssm_role.arn
}

output "ec2_ssm_role_id" {
  description = "ID of the EC2 SSM role"
  value       = aws_iam_role.ec2_ssm_role.id
}

output "ec2_ssm_profile_arn" {
  description = "ARN of the EC2 SSM instance profile"
  value       = aws_iam_instance_profile.ec2_ssm_profile.arn
}

output "ec2_ssm_profile_id" {
  description = "ID of the EC2 SSM instance profile"
  value       = aws_iam_instance_profile.ec2_ssm_profile.id
}
